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
		@requestURI = "/api/v1.1/listDelivery?uuid=#{current_user.uuid}"
		@delivery = JSON.parse(ApiController::SyncProcess.new("#{@requestURI}").getRequest())

		@requestURI = "/api/v1.1/listDownload?uuid=#{current_user.uuid}"
		@download = JSON.parse(ApiController::SyncProcess.new("#{@requestURI}").getRequest())
  end
end