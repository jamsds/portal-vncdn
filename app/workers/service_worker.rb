class ServiceWorker
  class StopService
  	include Sidekiq::Worker

  	def perform(id)
  		# Concept
  		# General email only receive username, and then exec email information with this username
  		# E.g which every user only one username, we can find name of user by username in template
	  	@id = id

			@requestURI = "/api/v1.1/customerDelivery/?id=#{@id}"
			@delivery = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").getRequest())

			@delivery.each do |delivery|
				@requestURI = "/cdn/#{delivery["id"]}/d/stop?originUrl=#{delivery["originUrl"]}&streamingService=#{delivery["streamingService"]}"
				ApplicationController::SyncProcess.new("#{@requestURI}").postRequest()
			end

			@requestURI = "/api/v1.1/customerDownload/?id=#{@id}"
			@download = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").getRequest())

			@download.each do |download|
				@requestURI = "/cdn/#{download["id"]}/f/stop?streamingService=#{download["streamingService"]}"
				ApplicationController::SyncProcess.new("#{@requestURI}").postRequest()
			end

	    # NotificationMailer.trial_email(@id).deliver
	  end
  end
end