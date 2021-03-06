class DeliveryController < ApplicationController
	require 'will_paginate/array'
	before_action :verify_subscription, except: [:deliveryStop]

	# Set Request Method
	before_action :post_method, only: [:deliveryAdd, :deliveryReport, :deliveryLog, :deliveryCreatePolicy]
	before_action :get_method, only: [:delivery, :deliveryDetail, :deliveryEdit, :deliveryPolicy]
	before_action :put_method, only: [:deliveryUpdate, :deliveryStop, :deliveryStart, :deliveryUpdatePolicy]
	before_action :delete_method, only: [:deliveryDelete, :deliveryDeletePolicy]

	# Set End Point Request
	before_action :cdn_endpoint, only: [:delivery, :deliveryDetail, :deliveryReport, :deliveryAdd, :deliveryLog, :deliveryEdit, :deliveryUpdate, :deliveryStop, :deliveryStart, :deliveryDelete, :deliveryPolicy, :deliveryCreatePolicy, :deliveryEditPolicy, :deliveryUpdatePolicy]

	def delivery
		@domainList = []

		if params[:per_page].nil?
	  	params[:per_page] = 10
	  end

		@requestURI = "/v1.0/customers/#{current_user.uuid}/domains"
		@delivery = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

		@delivery.each do |delivery|
			@domainList << delivery
		end

		@requestURI = "/v1.0/customers/#{current_user.uuid}/filedownloads"
		@download = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

		@download.each do |download|
			@domainList << download
		end

		@domainItems = @domainList.paginate(:page => params[:page], :per_page => params[:per_page])
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryDetail
  	if params[:dtype] == "d"
	  	@requestURI = "/v1.0/domains/#{params[:propertyId]}"
  	elsif params[:dtype] == "f"
	  	@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
		end

		@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryEdit
  	if params[:dtype] == "d"
	  	@requestURI = "/v1.0/domains/#{params[:propertyId]}"
  	elsif params[:dtype] == "f"
	  	@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
		end

		@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryReport
  	if params[:domain].present?
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
			@totalBandwidth = 0
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
					@totalBandwidth += stamp["value"]
					@bandwidthValue << stamp["value"]
				end
			end

			@maxBandwidth = @bandwidthValue.map(&:to_i).max
			
			@avgBandwidth = @totalBandwidth/@totalValues
		else
			redirect_to cdn_path
		end
	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryLog
  	if params[:domain].present? || params[:for].present?
	  	endTime = Time.now.utc 
		  @endTime = endTime.strftime("%Y-%m-%dT%H:%M:%SZ")

	  	if params[:range].nil?
		    startTime = endTime - 4.hours
		  elsif params[:range] == "1"
		  	startTime = endTime - 1.hours
		  elsif params[:range] == "8"
		  	startTime = endTime - 8.hours
		  elsif params[:range] == "24"
		  	startTime = endTime - 1.days
		  end

		  @startTime = startTime.strftime("%Y-%m-%dT%H:05:00Z")

		  if params[:domain].nil?
		  	params[:domain] = params[:for]
		  end

		  if params[:per_page].nil?
		  	params[:per_page] = 10
		  end

	  	@requestURI = "/v1.1/log/list"
			@requestBody = "{\"domains\":[\"#{params[:domain]}\"],\"startTime\":\"#{@startTime}\",\"endTime\":\"#{@endTime}\"}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			@timestamps = []
			@items = []

			@response.each do |response|
				response["logs"].each do |log|
					@timestamps << log["timestamp"]
					log["values"].each do |item|
						@items << item
					end
				end
			end

			@logItems = @timestamps.zip(@items).paginate(:page => params[:page], :per_page => params[:per_page])
		else
			redirect_to cdn_path
		end
	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryAdd
  	if params[:ftpPassword].nil?
	  	@requestURI = "/v1.0/domains"
			@requestBody = "{\"name\":\"#{params[:deliveryUrl]}\",\"customerId\":#{current_user.uuid},\"originUrl\":\"#{params[:originUrl]}\",\"streamingService\":#{params[:streamingService]},\"active\":true}"
		else
			if params[:ftpPassword] != params[:ftpPasswordConfirm]
	      flash[:confirm_notice] = "Error! Confirm password not match, please check again."
	      redirect_back(fallback_location: root_path)
	      return
	    else
	    	@requestURI = "/v1.0/filedownloads"
				@requestBody = "{\"name\":\"#{params[:deliveryUrl]}\",\"customerId\":#{current_user.uuid},\"originUrl\":\"\",\"ftpPassword\":\"#{params[:ftpPassword]}\",\"streamingService\":#{params[:streamingService]},\"active\":true}"
	    	@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
	    end
		end

		if @response
			redirect_to cdn_path
		end

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryUpdate
  	if params[:deliveryType].nil?
	  	@requestURI = "/v1.0/domains/#{params[:propertyId]}"
			@requestBody = "{\"originUrl\":\"#{params[:originUrl]}\",\"streamingService\":#{params[:streamingService]},\"active\":#{params[:deliveryStatus]}}"
			@response = RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

			if @response
				redirect_to cdn_path
			end
		elsif params[:deliveryType] == "f"
			if params[:ftpPassword].nil?
				@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
				@requestBody = "{\"streamingService\":#{params[:streamingService]},\"active\":#{params[:deliveryStatus]}}"
			else
				@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}/change_password"
				@requestBody = "{\"ftpPassword\":\"#{params[:ftpPassword]}\"}"
			end

			@response = RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

			if @response
				redirect_to cdn_path
			end
		end

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryStop
  	if params[:dtype] == "d"
  		@requestURI = "/v1.0/domains/#{params[:propertyId]}"
			@requestBody = "{\"originUrl\":\"#{params[:originUrl]}\",\"streamingService\":#{params[:streamingService]},\"active\":false}"
		elsif params[:dtype] == "f"
			@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
			@requestBody = "{\"streamingService\":#{params[:streamingService]},\"active\":false}"
  	end

  	@response = RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

  	if @response
			redirect_back(fallback_location: root_path)
		end

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryStart
  	if params[:dtype] == "d"
  		@requestURI = "/v1.0/domains/#{params[:propertyId]}"
			@requestBody = "{\"originUrl\":\"#{params[:originUrl]}\",\"streamingService\":#{params[:streamingService]},\"active\":true}"
		elsif params[:dtype] == "f"
			@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
			@requestBody = "{\"streamingService\":#{params[:streamingService]},\"active\":true}"
  	end

  	@response = RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

  	if @response
			redirect_back(fallback_location: root_path)
		end

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryDelete
  	if params[:dtype] == "d"
  		@requestURI = "/v1.0/domains/#{params[:propertyId]}"
  	elsif params[:dtype] == "f"
	  	@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
		end

		@response = RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

		if @response
			redirect_to cdn_path
		end

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
  end

  def deliveryPolicy
  	if params[:ptype] == 'a'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/access_controls"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			@whitelists = []
			@blacklists = []
			@tokens = []

			@response.each do |item|
				if item["type"] == "allow"
					@whitelists << item
				elsif item["type"] == "deny"
					@blacklists << item
				elsif item["type"] == "token"
					@tokens << item
				end
			end
		elsif params[:ptype] == 'c'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/cache_controls"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			@caches = []

			@response.each do |item|
				@caches << item
			end
		elsif params[:ptype] == 'r'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/redirections"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			@redirects = []

			@response.each do |item|
				@redirects << item
			end
		elsif params[:ptype] != 'a' || params[:ptype] != 'c' || params[:ptype] != 'r'
			redirect_to "/cdn/#{params[:propertyId]}/d"
		end

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	end

	def deliveryCreatePolicy
		if params[:ptype] == 'a'
			@ip = Regexp.new('^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')
			@subnet = Regexp.new('([0-9]|[0-9]\d|1\d{2}|2[0-4]\d|25[0-5])(\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])){3}\/\d+')

			if (params[:subnet] =~ @ip) != 0 && (params[:subnet] =~ @subnet) != 0
				flash[:confirm_notice] = "IP Restriction invalid. Please check again."
	      redirect_back(fallback_location: root_path)
	      return
			end

			@requestURI = "/v1.0/services/#{params[:propertyId]}/access_controls"
			@requestBody = "{\"name\":\"#{params[:name]}\",\"type\":\"#{params[:type]}\",\"matchType\":\"#{params[:matchType]}\",\"url\":\"#{params[:url]}\",\"subnet\":\"#{params[:subnet]}\",\"location\":\"#{params[:location]}\"}"
		elsif params[:ptype] == 'c'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/cache_controls"
			@requestBody = "{\"name\":\"#{params[:name]}\",\"matchType\":\"#{params[:matchType]}\",\"url\":\"#{params[:url]}\",\"hostHeader\":\"#{params[:hostHeader]}\",\"ttl\":\"#{params[:ttl]}\",\"ignoreClientNoCache\":\"#{params[:ignoreClientNoCache]}\",\"ignoreOriginNoCache\":\"#{params[:ignoreOriginNoCache]}\",\"ignoreQueryString\":\"#{params[:ignoreQueryString]}\"}"
		elsif params[:ptype] == 'r'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/redirections"
			@requestBody = "{\"name\":\"#{params[:name]}\",\"matchType\":\"#{params[:matchType]}\",\"url\":\"#{params[:url]}\",\"redirectionURL\":\"#{params[:redirectionURL]}\",\"statusCode\":\"#{params[:statusCode]}\"}"
		end

		RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

		redirect_to "/cdn/#{params[:propertyId]}/#{params[:dtype]}/policies/#{params[:ptype]}"

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	end

	def deliveryUpdatePolicy
		if params[:ptype] == 'a'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/access_controls/#{params[:policyId]}"
			@requestBody = "{\"name\":\"#{params[:name]}\",\"type\":\"#{params[:type]}\",\"matchType\":\"#{params[:matchType]}\",\"url\":\"#{params[:url]}\",\"subnet\":\"#{params[:subnet]}\",\"location\":\"#{params[:location]}\"}"
		elsif params[:ptype] == 'c'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/cache_controls/#{params[:policyId]}"
			@requestBody = "{\"name\":\"#{params[:name]}\",\"matchType\":\"#{params[:matchType]}\",\"url\":\"#{params[:url]}\",\"hostHeader\":\"#{params[:hostHeader]}\",\"ttl\":\"#{params[:ttl]}\",\"ignoreClientNoCache\":\"#{params[:ignoreClientNoCache]}\",\"ignoreOriginNoCache\":\"#{params[:ignoreOriginNoCache]}\",\"ignoreQueryString\":\"#{params[:ignoreQueryString]}\"}"
		elsif params[:ptype] == 'r'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/redirections/#{params[:policyId]}"
			@requestBody = "{\"name\":\"#{params[:name]}\",\"matchType\":\"#{params[:matchType]}\",\"url\":\"#{params[:url]}\",\"redirectionURL\":\"#{params[:redirectionURL]}\",\"statusCode\":\"#{params[:statusCode]}\"}"
		end

		RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()

		redirect_to "/cdn/#{params[:propertyId]}/#{params[:dtype]}/policies/#{params[:ptype]}"

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	end

	def deliveryDeletePolicy
		if params[:ptype] == 'a'
			@requestURI = "/v1.0/services/#{params[:propertyId]}/access_controls/#{params[:policyId]}"
			RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
		end

		redirect_back(fallback_location: root_path)

	rescue TypeError => e
    flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	rescue SocketError => e
  	flash[:method_error] = e.message
  	flash[:reffer_error] = "Controller: #{controller_name} - Action: #{action_name} - UUID: #{current_user.username}"
  	redirect_to errors_path
	end

  private
  	def verify_subscription
  		if current_user.subscription.nil? || current_user.subscription.status != 1
  			redirect_to account_subscription_path
  		end
  	end
end