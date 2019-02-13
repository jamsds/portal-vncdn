class ApplicationController < ActionController::Base
	require "uri"
  require "net/http"
  require "date"

  class SyncProcess
    def initialize(requestURI)
      @requestURI = requestURI
    end

    def postRequest
      url = URI("http://127.0.0.1:3000"+@requestURI)

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url)
      response = http.request(request).read_body
    end

    def getRequest
      url = URI("http://127.0.0.1:3000"+@requestURI)

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      response = http.request(request).read_body
    end
  end
end