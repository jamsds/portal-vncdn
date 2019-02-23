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

		@startDateOfThisMonth = Date.current.beginning_of_month.strftime("%B %d")
		@dateTodayOfThisMonth = Date.current.strftime("%d, %Y")

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
	    @totalTime = []

	    @currentBandwidth = []
	    @customerBandwidth = []
	    @currentStorage = []
	    @customerStorage = []

	    current_user.bandwidths.order("created_at ASC").each do |time|
	    	@totalTime << time.created_at.strftime("%Y-%m-%dT%H:%M:00Z")
	    end

	    @customer.each do |customer|
	    	customer.bandwidths.order("created_at ASC").each do |bandwidth|
	    		@customerBandwidth << bandwidth.bandwidth_usage * 1000.00
	    	end
	    	customer.storages.order("created_at ASC").each do |storage|
	    		@customerStorage << storage.storage_usage * 1000.00
	    	end
	    end

	    current_user.bandwidths.order("created_at ASC").each do |bandwidth|
	    	@currentBandwidth << bandwidth.bandwidth_usage * 1000.00
	    end

	    current_user.storages.order("created_at ASC").each do |storage|
	    	@currentStorage << storage.storage_usage * 1000.00
	    end

	    if @customer.present?
		    @currentBandwidth.zip(@customerBandwidth).each do |current, customer|
		    	@totalBandwidth << current + customer
		    end
		    @currentStorage.zip(@customerStorage).each do |current, customer|
		    	@totalStorage << current + customer
		    end
		  else
		  	@totalBandwidth = @currentBandwidth
		  	@totalStorage = @currentStorage
		  end
	  end

	rescue TypeError => e
		flash[:type_error] = e.message
  	redirect_back(fallback_location: root_path)
  rescue NoMethodError => e
  	flash[:method_error] = e.message
  	redirect_back(fallback_location: root_path)
	end
end