class Api::V1Controller < ApiController
	def index
		render json: "{\"code\":\"URI.Invalid\",\"message\":\"URI is empty or invalid.\"}"
	end

	## Web Acceleration
	def listDomain
		@requestURI = "/v1.0/customers/#{$UUID}/domains"
		render json: RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
	end
end