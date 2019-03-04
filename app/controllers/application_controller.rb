class ApplicationController < ActionController::Base
	require "uri"
  require "net/http"
  require "date"

  # Payment
  require "stripe"
  
	# Set Variables Request
	before_action :set_variables
	before_action :set_request_host

	# Swiftfederation Config
	$ACCESS_KEY_ID = '0cavp8cG1vd149Oy'
	$ACCESS_KEY_SECRET = 'M6yji4lILlMz9E9zd869YyG7pf1Q811a'
	$X_SPD_NONCE = rand(10000..99999)
	$ROOT_ID = "30133"

	protect_from_forgery

	def set_request_host
	  Thread.current[:request_host] = request.host
	end

	class SyncProcess
    def initialize(requestURI)
      @requestURI = requestURI
    end

    def postRequest
      url = URI("http://127.0.0.1:8000"+@requestURI)

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url)
      response = http.request(request).read_body
    end

    def getRequest
      url = URI("http://127.0.0.1:8000"+@requestURI)

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      response = http.request(request).read_body
    end
  end

  class FormatNumber
    include ActionView::Helpers::NumberHelper

    def initialize(number)
      @number = number
    end

    def formatHumanSize
      number_to_human_size(@number, separator: ".", delimiter: ",")
    end

    def formatCurrency
      number_to_currency(@number, unit: "₫", precision: 2, separator: ".", delimiter: ",", format: "%u%n")
    end

    def formatPricing
      number_to_currency(@number, unit: "₫", precision: 0, separator: ".", delimiter: ",", format: "%u%n")
    end

    def formatPercent
      number_to_percentage(@number, precision: 2) 
    end
  end

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