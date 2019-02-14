class DefaultController < ApplicationController
	before_action :authenticate_user!

	def index
		if current_user.uuid.nil?
			@requestURI = "/api/v1.1/createCustomer/?name=#{current_user.username}"
			@response = JSON.parse(ApiController::SyncProcess.new("#{@requestURI}").postRequest())

			current_user.update(uuid: @response["id"])
		end
	end

	def delivery
		@deliveryURI = "/v1.0/customers/#{current_user.uuid}/domains"
		@delivery = JSON.parse(ApiController::RestAPI.new("#{@deliveryURI}", "#{@requestBody}").openRequest())

		@downloadURI = "/v1.0/customers/#{current_user.uuid}/filedownloads"
		@download = JSON.parse(ApiController::RestAPI.new("#{@downloadURI}", "#{@requestBody}").openRequest())
  end
end