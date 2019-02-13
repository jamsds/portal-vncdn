class DefaultController < ApplicationController
	def index
		@requestURI = "/api"
		response = ApplicationController::SyncProcess.new("#{@requestURI}").getRequest()
		@response = JSON.parse(response)
		puts @response
	end

	def api
		render :json => { message: "success" }.to_json
	end
end