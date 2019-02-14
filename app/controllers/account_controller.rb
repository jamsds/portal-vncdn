class AccountController < ApplicationController
  before_action :authenticate_user!

  def index
		@user_child = User.where(parent_uuid: current_user.username)

		@requestURI = "/api/v1.1/listDomain"
		@response = JSON.parse(ApiController::SyncProcess.new("#{@requestURI}").getRequest())

		puts @response
  end
end