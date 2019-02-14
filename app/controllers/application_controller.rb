class ApplicationController < ActionController::Base
	require "uri"
  require "net/http"
  require "date"

  $ACCESS_KEY_ID = '0cavp8cG1vd149Oy'
  $ACCESS_KEY_SECRET = 'M6yji4lILlMz9E9zd869YyG7pf1Q811a'
  $X_SPD_NONCE = rand(10000..99999)
  $ROOT_ID = "30133"

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
      else
        $UUID = ""
      end

      $X_SPD_DATE = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    end
end