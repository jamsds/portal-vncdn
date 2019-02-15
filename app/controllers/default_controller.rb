class DefaultController < ApplicationController
	before_action :authenticate_user!

	# Set Request Method
	before_action :post_method, only: [:index, :deliveryAdd, :deliveryReport]
	before_action :get_method, only: [:delivery, :deliveryDetail]

	# Set End Point Request
	before_action :base_endpoint, only: [:index]
	before_action :cdn_endpoint, only: [:delivery, :deliveryDetail, :deliveryReport, :deliveryAdd]

	def index
		if current_user.uuid.nil?
			@requestURI = "/v1.1/createCustomer/"
			@requestBody = "{\"name\":\"#{current_user.username}\",\"parentId\":#{$ROOT_ID},\"type\":2,\"partnership\":1}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			current_user.update(uuid: @response["id"])
		end
	end

	def delivery
		if params[:deliveryAction].nil?
			@requestURI = "/v1.0/customers/#{current_user.uuid}/domains"
			@delivery = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			@requestURI = "/v1.0/customers/#{current_user.uuid}/filedownloads"
			@download = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
		end
  end

  def deliveryDetail
  	if params[:type] == "d"
	  	@requestURI = "/v1.0/domains/#{params[:propertyId]}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
  	elsif params[:type] == "f"
	  	@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
		end
  end

  def deliveryReport
  	endTime = Time.now.utc 
	  @endTime = endTime.strftime("%Y-%m-%dT%H:%M:00Z")

  	if params[:range].nil?
	    startTime = endTime - 4.hours
	  elsif params[:range] == "1"
	  	startTime = endTime - 1.hours
	  elsif params[:range] == "8"
	  	startTime = endTime - 8.hours
	  elsif params[:range] == "24"
	  	startTime = endTime - 1.days
	  end

	  @startTime = startTime.strftime("%Y-%m-%dT%H:%M:00Z")

  	@requestURI = "/v1.1/report/volume"
		@requestBody = "{\"domains\":[\"#{params[:domain]}\"],\"startTime\":\"#{@startTime}\",\"endTime\":\"#{@endTime}\",\"fillFixedTime\":\"true\",\"interval\":\"#{@interval}\"}"
		@traffic = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

		@timestamp = []
		@trafficValue = []
		@totalValues = 0

		@traffic.each do |item|
			item["volumes"].each do |stamp|
				@timestamp << stamp["timestamp"]
				@trafficValue << stamp["value"]
			end
		end

		@requestURI = "/v1.0/report/origin_request_number"
		@requestBody = "{\"domains\":[\"#{params[:domain]}\"],\"startTime\":\"#{@startTime}\",\"endTime\":\"#{@endTime}\",\"fillFixedTime\":\"true\",\"interval\":\"#{@interval}\"}"
		@request = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

		@requestValue = []

		@request.each do |item|
			item["originReqNums"].each do |stamp|
				@requestValue << stamp["value"]
			end
		end
		
		@bandwidthValue = []

		@requestURI = "/v1.0/report/origin_bandwidth"
		@requestBody = "{\"domains\":[\"#{params[:domain]}\"],\"startTime\":\"#{@startTime}\",\"endTime\":\"#{@endTime}\",\"fillFixedTime\":\"true\",\"interval\":\"#{@interval}\"}"
		@bandwith = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

		@bandwith.each do |item|
			item["originBandwidths"].each do |stamp|
				@totalValues += 1
				@bandwidthValue << stamp["value"]
			end
		end

		puts @totalValues

		@maxBandwidth = @bandwidthValue.map(&:to_i).max
		@avgBandwidth = @maxBandwidth/@totalValues
  end

  def deliveryAdd
  	if params[:ftpPassword].nil?
	  	@requestURI = "/v1.0/domains"
			@requestBody = "{\"name\":\"#{params[:deliveryUrl]}\",\"customerId\":#{current_user.uuid},\"originUrl\":\"#{params[:originUrl]}\",\"streamingService\":#{params[:streamingService]},\"active\":true}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
		else
			@requestURI = "/v1.0/filedownloads"
			@requestBody = "{\"name\":\"#{params[:deliveryUrl]}\",\"customerId\":#{current_user.uuid},\"originUrl\":\"\",\"ftpPassword\":\"#{params[:ftpPassword]}\",\"streamingService\":#{params[:streamingService]},\"active\":true}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
		end

		if @response
			redirect_to delivery_path
		end
  end
end