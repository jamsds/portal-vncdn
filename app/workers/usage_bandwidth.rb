require 'sidekiq-scheduler'

class UsageBandwidth
  include Sidekiq::Worker

  def perform
  	# Concept
    ## Bandwidth usage will calculate every 0,15,30,45 minute of an hour, every bandwidth used will generate a cash log for customer follow what their use on a day
    ## monthly data for report
  	@thisMonth = Date.today.strftime("%Y-%m")

  	## Time to generate the log of Swiftfederation slow more 20 minutes than real-time, so startTime needs to subtract 20 minutes
    ## Time.now using 20 minutes with number*second
  	endTime = Time.now.utc
    @endTime = (endTime - 20*60).strftime("%Y-%m-%dT%H:%M:00Z")

    # Last update subtract 5 minutes because we need delay to make sure data on Swiftfederation update complete
    @last_update = (endTime - 15*60).strftime("%Y-%m-%dT%H:%M:00Z")

		# Run if subscription status is active
		Subscription.where(status: 1).each do |subscription|
			# Find user with subscription is active
			@user = User.find(subscription.user_id)

			@bwdLimit = subscription.bwd_limit
			@bwdTotal = 0

			# Because every bandwidth log will be generated once time per month,
			# so we need to a defining month of logs, if it exists we don't need to create new
			# puts user.bandwidths.where(monthly: @thisMonth).present?
			if !@user.bandwidths.where(monthly: @thisMonth).present?
				@user.bandwidths.create(monthly: @thisMonth)
			end

			# Set start time is last update
			if @user.bandwidths.find_by(monthly: @thisMonth).last_update.present?
				@startTime = @user.bandwidths.find_by(monthly: @thisMonth).last_update.strftime("%Y-%m-%dT%H:%M:00Z")
				if (Date.current - @user.bandwidths.find_by(monthly: @thisMonth).last_update.to_date).to_i != 0
					@user.bandwidths.find_by(monthly: @thisMonth).update(last_update: @last_update)
					return
				end
			else
				@startTime = @endTime
			end

			# Time format for testing
			# @startTime = "2019-02-20T00:00:00Z"
			# @endTime = "2019-02-20T04:00:00Z"

			# Instead, each log is bandwidth update, a last_update record will be updated time of last sidekiq run
			@user.bandwidths.find_by(monthly: @thisMonth).update(last_update: @last_update)

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
				bandwidths = ApplicationController::SyncProcess.new("#{@requestURI}").postRequest()

				if bandwidths != "[]"
					@bandwidths = JSON.parse(bandwidths)
					@bandwidths.each do |bandwidth|
						bandwidth["volumes"].each do |value|
							# Test
							# puts value["value"]
							@bwdTotal += value["value"]

							# Data save on database be converted MB for decrease the decimal string length
							# Update new bandwidth value by increase data of bandwidth log
							@user.bandwidths.find_by(monthly: @thisMonth).increment! :bandwidth_usage, value["value"]/1000.00
						end
					end
				end
			end

			if @bwdTotal > @bwdLimit
				subscription.update(status: 2)
			end
		end
  end
end