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
end