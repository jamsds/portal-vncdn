class DefaultController < ApplicationController
	before_action :authenticate_user!

	# Set Request Method
	before_action :post_method, only: [:index]

	# Set End Point Request
	before_action :base_endpoint, only: [:index]

	def errors
		@requested_path = request.path
		flash[:routes_error] = @requested_path
	end
	
	def index
		if current_user.uuid.nil?
			@requestURI = "/v1.1/createCustomer/"
			@requestBody = "{\"name\":\"#{current_user.username}\",\"parentId\":#{$ROOT_ID},\"type\":2,\"partnership\":1}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			current_user.update(uuid: @response["id"])
		end
		if !current_user.credit.present?
			Credit.create(user_id: current_user.id)
		end
		if !current_user.notification.present?
			Notification.create(user_id: current_user.id)
		end

		# Define data usage on this month
		@thisMonth = Date.today.strftime("%Y-%m")
		@previousMonth = (Date.current - 1.month).strftime("%Y-%m")


    if current_user.credit.transactions.nil? || current_user.credit.transactions.where(monthly: @thisMonth, transaction_type: "Automatic Payment", status: "succeeded").present?
      @previousPrice = @currentPrice = @stgPreviousMonth = @bwdPreviousMonth = @stgCurrentMonth = @bwdCurrentMonth = 0
    elsif current_user.subscription.nil?
      @previousPrice = @currentPrice = @stgPreviousMonth = @bwdPreviousMonth = @stgCurrentMonth = @bwdCurrentMonth = 0
    else
      bwdPrice = current_user.subscription.bwd_price
      stgPrice = current_user.subscription.stg_price

      if current_user.bandwidths.find_by(monthly: @previousMonth).present?
	      @bwdPreviousMonth = current_user.bandwidths.find_by(monthly: @previousMonth).bandwidth_usage * 1000.00
	    else
	      @bwdPreviousMonth = 0
	    end

	    if current_user.storages.find_by(monthly: @previousMonth).present?
	      @stgPreviousMonth = current_user.storages.find_by(monthly: @previousMonth).storage_usage * 1000.00
	    else
	      @stgPreviousMonth = 0
	    end

      if current_user.bandwidths.find_by(monthly: @thisMonth).present?
        @bwdCurrentMonth = current_user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage * 1000.00
      else
        bwdUsage = 0
      end

      if current_user.storages.find_by(monthly: @thisMonth).present?
        @stgCurrentMonth = current_user.storages.find_by(monthly: @thisMonth).storage_usage * 1000.00
      else
        stgUsage = 0
      end

	    @previousPrice = (stgPrice * (@stgPreviousMonth / 1000000000.00)) + (bwdPrice * (@bwdPreviousMonth / 1000000000.00))
      @currentPrice = (stgPrice * (@stgCurrentMonth / 1000000000.00)) + (bwdPrice * (@bwdCurrentMonth / 1000000000.00))

      @percent = (@currentPrice/@previousPrice) * 100.00
    end

    if current_user.accountType == 2
	    @totalBandwidth = []
	    @totalStorage = []
	    @totalMonths = []

	    @customers = [current_user.id]

	    thisYear = Date.current.strftime("%Y")

	    ["01","02","03","04","05","06","07","08","09","10","11","12"].each do |month|
	    	@totalMonths << "#{thisYear}-#{month}"
	    end

	    if User.where(parent_uuid: current_user.username).present?
		    User.where(parent_uuid: current_user.username).each do |customer|
		    	@customers << customer.id
		    end
		  end

		  @totalMonths.each do |monthly|
		  	@monthlyBandwidth = 0
		  	@monthlyStorage = 0

		  	Bandwidth.where(monthly: monthly, user_id: @customers).each do |bandwidth|
		  		@monthlyBandwidth += bandwidth.bandwidth_usage * 1000.00
		  	end

		  	Storage.where(monthly: monthly, user_id: @customers).each do |storage|
		  		@monthlyStorage += storage.storage_usage * 1000.00
		  	end

		  	@totalBandwidth << @monthlyBandwidth
		  	@totalStorage << @monthlyStorage
		  end
	  end

  rescue NoMethodError => e
  	if e.message == "undefined method `transactions' for nil:NilClass"
  		redirect_to root_path
  	else
  		flash[:method_error] = e.message
  		flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  		redirect_to errors_path
  	end
	end
end