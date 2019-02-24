class DefaultController < ApplicationController
	before_action :authenticate_user!

	# Set Request Method
	before_action :post_method, only: [:index]

	# Set End Point Request
	before_action :base_endpoint, only: [:index]
	
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

    if current_user.credit.transactions.nil? || current_user.credit.transactions.where(monthly: @thisMonth, transaction_type: "Automatic Payment", status: "succeeded").present?
      @totalPrice = 0
    elsif current_user.subscription.nil?
      @totalPrice = 0
    else
      bwdPrice = current_user.subscription.bwd_price
      stgPrice = current_user.subscription.stg_price

      if current_user.bandwidths.where(monthly: @thisMonth).present?
        bwdUsage = current_user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage / 1000000.00
      else
        bwdUsage = 0
      end

      if current_user.storages.where(monthly: @thisMonth).present?
        stgUsage = current_user.storages.find_by(monthly: @thisMonth).storage_usage / 1000000.00
      else
        stgUsage = 0
      end

      @totalPrice = (stgPrice * stgUsage) + (bwdPrice * bwdUsage)
    end

    @customer = User.where(parent_uuid: current_user.username)

    if current_user.accountType == 2
	    @totalBandwidth = []
	    @totalStorage = []
	    @totalMonths = []

	    thisYear = Date.current.strftime("%Y")

	    ["01","02","03","04","05","06","07","08","09","10","11","12"].each do |month|
	    	@totalMonths << "#{thisYear}-#{month}"
	    end

		  @totalMonths.each do |monthly|
		  	@monthlyBandwidth = 0

		  	Bandwidth.where(monthly: monthly).each do |bandwidth|
		  		@monthlyBandwidth += bandwidth.bandwidth_usage
		  	end

		  	@totalBandwidth << @monthlyBandwidth
		  end

		  @totalMonths.each do |monthly|
		  	@monthlyStorage = 0

		  	Storage.where(monthly: monthly).each do |storage|
		  		@monthlyStorage += storage.storage_usage
		  	end

		  	@totalStorage << @monthlyStorage
		  end
	  end

  rescue NoMethodError => e
  	flash[:method_error] = e.message
  	redirect_back(fallback_location: root_path)
	end
end