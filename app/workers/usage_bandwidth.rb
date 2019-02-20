require 'sidekiq-scheduler'

class UsageBandwidth
  include Sidekiq::Worker

  def perform
  	@thisMonth = Date.today.strftime("%Y-%m")

  	endTime = Time.now.utc
    @endTime = (endTime - 20*60).strftime("%Y-%m-%dT%H:%M:00Z")
    # @endTime = "2019-02-20T04:00:00Z"

    @last_update = (endTime - 15*60).strftime("%Y-%m-%dT%H:%M:00Z")

		# Run if subscription status is active
		Subscription.where(status: 1).each do |subscription|
			# Find user with subscription is active
			@user = User.find(subscription.user_id)

			# Create bandwidth record if user is new user
			if !@user.bandwidths.where(monthly: @thisMonth).present?
				@user.bandwidths.create(monthly: @thisMonth, last_update: @last_update)
			end

			# Set start time is last update
			if @user.bandwidths.find_by(monthly: @thisMonth).present?
				startTime = @user.bandwidths.find_by(monthly: @thisMonth).last_update
			else
				startTime = endTime - 20*60
			end

			@startTime = startTime.strftime("%Y-%m-%dT%H:%M:00Z")
			# @startTime = "2019-02-20T00:00:00Z"

			@listDomain = []

			@requestURI = "/api/v1.1/customerDelivery/?id=#{@user.uuid}"
			@deliverys = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").getRequest())

			@deliverys.each do |delivery|
				@listDomain << delivery
			end

			@requestURI = "/api/v1.1/customerDownload/?id=#{@user.uuid}"
			@downloads = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").getRequest())

			@downloads.each do |download|
				@listDomain << download
			end

			@listDomain.each do |domain|
				# puts domain["name"]
				@requestURI = "/api/v1.1/customerVolume/?domain="+domain["name"]+"&startTime="+@startTime+"&endTime="+@endTime
				@bandwidths = JSON.parse(ApplicationController::SyncProcess.new("#{@requestURI}").postRequest())

				@bandwidths.each do |bandwidth|
					bandwidth["volumes"].each do |value|
						puts value["value"]
						
						@user.bandwidths.find_by(monthly: @thisMonth, last_update: @last_update).increment! :bandwidth_usage, value["value"]/1000.00
					end
				end
			end
		end
  end
end