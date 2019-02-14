class ApiController < ApplicationController
	# For test Postman
	skip_before_action :verify_authenticity_token

	# Set Variables Request
	before_action :set_variables

	# Set Request Method
	before_action :get_method, only: [:listDomain]
	before_action :post_method, only: [:createCustomer]

	# Set End Point Request
	before_action :base_endpoint, only: [:createCustomer]
	before_action :cdn_endpoint, only: [:listDomain]

	# Generate signatureAlgorithm
	class Algorithm
		def initialize(requestMethod, requestURI, requestBody)
	    @requestMethod, @requestURI, @requestBody = requestMethod, requestURI, requestBody
	  end

	  def signatureAlgorithm
	  	"#{@requestMethod}\n#{@requestURI}\n#{$X_SPD_DATE}\n#{$X_SPD_NONCE}\n#{$ACCESS_KEY_ID}\n#{@requestBody}"
	  end
	end

	# Generate Signature
	class Signature
	  def initialize(signatureAlgorithm)
	    @signatureAlgorithm = signatureAlgorithm
	  end

	  def buildSignature
	  	OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), $ACCESS_KEY_SECRET, @signatureAlgorithm)
	  end
	end

	# RestAPI
	class RestAPI
		def initialize(requestURI, requestBody)
			@requestURI, @requestBody = requestURI, requestBody
		end

		def openRequest
			url = URI($END_POINT+@requestURI)
			@requestSignature = Signature.new(Algorithm.new("#{$METHOD}", "#{@requestURI}", "#{@requestBody}").signatureAlgorithm()).buildSignature()

			https = Net::HTTP.new(url.host, url.port)
			https.use_ssl = true

			# Detect Method Request
			if $METHOD == "GET"
				request = Net::HTTP::Get.new(url)
			elsif $METHOD == "POST"
				request = Net::HTTP::Post.new(url)
			elsif $METHOD == "PUT"
				request = Net::HTTP::Put.new(url)
			elsif $METHOD == "PATCH"
				request = Net::HTTP::Patch.new(url)
			elsif $METHOD == "DELETE"
				request = Net::HTTP::Delete.new(url)
			end

			# Set Header Request
			request["Authorization"] = 'HMAC-SHA256 ' + $ACCESS_KEY_ID + ':' + @requestSignature
			request["Content-Type"] = 'application/json; charset=UTF-8'
			request["X-SFD-Date"] = $X_SPD_DATE
			request["X-SFD-Nonce"] = $X_SPD_NONCE

			request.body = @requestBody

			# Read Response
			response = https.request(request).body
		end
	end

	private
		def set_variables
			if user_signed_in?
				$UUID = current_user.uuid
			elsif
				$UUID = params[:uuid]
			else
				$UUID = ""
			end

			if !params[:propertyId].nil?
				@propertyId = params[:propertyId]
			end

			if !params[:id].nil?
				@id = params[:id]
			end

			if !params[:lfdName].nil?
				@lfdName = params[:lfdName]
			end

			if !params[:originUrl].nil?
				@originUrl = params[:originUrl]
			end

			if !params[:ftpPassword].nil?
				@ftpPassword = params[:ftpPassword]
			end

			if !params[:ftpPasswordRepeat].nil?
				@ftpPasswordRepeat = params[:ftpPasswordRepeat]
			end

			if !params[:streamingService].nil?
				@streamingService = params[:streamingService]
			end

			if !params[:active].nil?
				@active = params[:active]
			end

			if !params[:name].nil?
				@name = params[:name]
			end

			if !params[:type].nil?
				@type = params[:type]
			end

			if !params[:matchType].nil?
				@matchType = params[:matchType]
			end

			if !params[:url].nil?
				@url = params[:url]
			end

			if !params[:subnet].nil?
				@subnet = params[:subnet]
			end

			if !params[:location].nil?
				@location = params[:location]
			end

			if !params[:hostHeader].nil?
				@hostHeader = params[:hostHeader]
			end

			if !params[:ttl].nil?
				@ttl = params[:ttl]
			end

			if !params[:ignoreClientNoCache].nil?
				@ignoreClientNoCache = params[:ignoreClientNoCache]
			end

			if !params[:ignoreOriginNoCache].nil?
				@ignoreOriginNoCache = params[:ignoreOriginNoCache]
			end

			if !params[:ignoreQueryString].nil?
				@ignoreQueryString = params[:ignoreQueryString]
			end

			if !params[:redirectionURL].nil?
				@redirectionURL = params[:redirectionURL]
			end

			if !params[:statusCode].nil?
				@statusCode = params[:statusCode]
			end

			if !params[:domains].nil?
				@domains = params[:domains]
			end

			if !params[:startTime].nil?
				@startTime = params[:startTime]
			end

			if !params[:endTime].nil?
				@endTime = params[:endTime]
			end

			if !params[:interval].nil?
				@interval = params[:interval]
			end

			if !params[:urlPath].nil?
				@urlPath = params[:urlPath]
			end

			if !params[:serviceType].nil?
				@serviceType = params[:serviceType]
			end

			$X_SPD_DATE = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
		end

		def base_endpoint
			$END_POINT = 'https://base-api.swiftfederation.com'
		end

		def cdn_endpoint
			$END_POINT = 'https://cdn-api.swiftfederation.com'
		end

		def vod_endpoint
			$END_POINT = 'https://vms-api.swiftfederation.com'
		end

		def get_method
			$METHOD = "GET"
		end

		def post_method
			$METHOD = "POST"
		end

		def put_method
			$METHOD = "PUT"
		end

		def delete_method
			$METHOD = "DELETE"
		end
end