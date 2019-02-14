class DefaultController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if user_signed_in?
			@requestURI = "/api"
			response = ApplicationController::SyncProcess.new("#{@requestURI}").getRequest()
			@response = JSON.parse(response)
			puts @response
		end
	end

	def api
		render :json => { message: "success" }.to_json
	end
end