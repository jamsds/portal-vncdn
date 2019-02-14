class Api::V1Controller < ApiController
	def index
		render json: "{\"code\":\"URI.Invalid\",\"message\":\"URI is empty or invalid.\"}"
	end

	def createCustomer
		@requestURI = "/v1.1/createCustomer/"
		@requestBody = "{\"name\":\"#{@name}\",\"parentId\":#{$ROOT_ID},\"type\":2,\"partnership\":1}"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
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
end