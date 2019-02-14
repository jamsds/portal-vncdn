class DefaultController < ApplicationController
	before_action :authenticate_user!

	def index
		@requestURI = "/api/v1.1/createCustomer/?name=#{current_user.username}"
		@response = JSON.parse(ApiController::SyncProcess.new("#{@requestURI}").postRequest())

		puts @response
	end
end