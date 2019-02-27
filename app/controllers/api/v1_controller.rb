class Api::V1Controller < ApiController
	# Set Request Method
	before_action :get_method, only: [:listDelivery, :customerDelivery, :customerStorage, :customerDownload]
	before_action :post_method, only: [:customerVolume]

	# Set End Point Request
	before_action :cdn_endpoint, only: [:customerDelivery, :customerDownload, :customerVolume, :customerStorage]

	def index
		render json: "{\"code\":\"URI.Invalid\",\"message\":\"URI is empty or invalid.\"}"
	end

	## Web Acceleration
	def listDelivery
		@requestURI = "/v1.0/customers/#{$UUID}/domains"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end

	## File Download
	def listDownload
		@requestURI = "/v1.0/customers/#{$UUID}/filedownloads"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end

	# Runtime Background
	def customerDelivery
		@requestURI = "/v1.0/customers/#{params[:id]}/domains"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end

	def customerDownload
		@requestURI = "/v1.0/customers/#{params[:id]}/filedownloads"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end

	def customerVolume
		@requestURI = "/v1.1/report/volume"
		@requestBody = "{\"domains\":[\"#{params[:domain]}\"],\"startTime\":\"#{params[:startTime]}\",\"endTime\":\"#{params[:endTime]}\",\"fillFixedTime\":\"false\",\"interval\":\"minute\"}"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end

	def customerStorage
		@requestURI = "/v1.0/filedownloads/#{params[:propertyId]}"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end

	# Check CNAME
	def checkCname
		if !params[:domain].nil?
			@domain = params[:domain]
		end

		url = URI("https://api.mojodns.com/api/dns/#{@domain}/CNAME")

		https = Net::HTTP.new(url.host, url.port)
		https.use_ssl = true

		request = Net::HTTP::Get.new(url)
		request["Authorization"] = "c067217a-fd14-45be-8ee5-6f6cd23ce49b"

		response = https.request(request)
		render json: response.read_body
	end

	# Check SSID
	def checkSSID
		if User.where(email: params[:email]).size == 0
			render json: "{\"status\":false}"
		else
			render json: "{\"status\":true}"
		end
	end
end