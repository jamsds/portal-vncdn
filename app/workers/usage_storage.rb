require 'sidekiq-scheduler'

class UsageStorage
  include Sidekiq::Worker

  def perform
    # Concept
    ## Storage usage will calculate every minute 0 of 0,4,8,12,16,20,24 hour of a day, storage used will be calculate to price and show on estimate usage of user
    @thisMonth = Date.today.strftime("%Y-%m")
    @last_update = Time.now.utc.strftime("%Y-%m-%dT%H:%M:00Z")

    Subscription.where(status: 1).each do |subscription|
			# Find user with subscription is active
			@user = User.find(subscription.user_id)

			# Because every storage log will be generated once time per month,
			# so we need to a defining month of logs, if it exists we don't need to create new
			if !@user.storages.where(monthly: @thisMonth).present?
				@user.storages.create(monthly: @thisMonth, last_update: @last_update)
			else
				# Instead, each log is storage update, a last_update record will be updated time of last sidekiq run
				@user.storages.find_by(monthly: @thisMonth).update(last_update: @last_update)
			end

			@requestURI = "/api/v1.1/customerDownload/?id=#{@user.uuid}"
			@domains = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").getRequest())

			@domains.each do |domain|
				# puts domain
				@requestURI = "/api/v1.1/customerStorage/?propertyId=#{domain["id"]}"
				@storages = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").postRequest())

				@user.storages.find_by(monthly: @thisMonth).update(storage_usage: @storages["diskUsage"]/1000.00)
			end
    end
  end
end