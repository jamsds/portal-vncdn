class ApplicationController < ActionController::Base
	require "uri"
  require "net/http"
  require "date"

  # Swiftfederation Config
	$ACCESS_KEY_ID = '0cavp8cG1vd149Oy'
	$ACCESS_KEY_SECRET = 'M6yji4lILlMz9E9zd869YyG7pf1Q811a'
	$X_SPD_NONCE = rand(10000..99999)
	$ROOT_ID = "30133"

	class SyncProcess
    def initialize(requestURI)
      @requestURI = requestURI
    end

    def postRequest
      url = URI("http://id.demo.vncdn.vn"+@requestURI)

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url)
      response = http.request(request).read_body
    end

    def getRequest
      url = URI("http://id.demo.vncdn.vn"+@requestURI)

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      response = http.request(request).read_body
    end
  end
end