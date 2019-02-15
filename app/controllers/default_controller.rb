class DefaultController < ApplicationController
	before_action :authenticate_user!

	# Set Request Method
	before_action :post_method, only: [:index]
	before_action :get_method, only: [:delivery]

	# Set End Point Request
	before_action :base_endpoint, only: [:index]
	before_action :cdn_endpoint, only: [:delivery]

	def index
		if current_user.uuid.nil?
			@requestURI = "/v1.1/createCustomer/"
			@requestBody = "{\"name\":\"#{current_user.username}\",\"parentId\":#{$ROOT_ID},\"type\":2,\"partnership\":1}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			current_user.update(uuid: @response["id"])
		end
	end

	def delivery
		@requestURI = "/v1.0/customers/#{current_user.uuid}/domains"
		@delivery = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

		@requestURI = "/v1.0/customers/#{current_user.uuid}/filedownloads"
		@download = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())
  end
end