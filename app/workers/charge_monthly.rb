require 'sidekiq-scheduler'

class ChargeMonthly
  include Sidekiq::Worker

  def perform
  	# Defind usage on this month
  	@thisMonth = Date.today.strftime("%Y-%m")

  	# Run if subscription status is active
		Subscription.where(status: 1).each do |subscription|
			# Find user with subscription is active
			@user = User.find(subscription.user_id)
			
      # Effect only with subscription type automatic payment
      if subscription.payment_type == 2
  			# Get bandwidth & storage usage on this month
  			bwdUsage = @user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage * 1000.00
        stgUsage = @user.storages.find_by(monthly: @thisMonth).storage_usage * 1000.00

        # Calculator Pricing
        totalPrice = (@user.subscription.stg_price * (stgUsage / 1000000000.00)) + (@user.subscription.bwd_price * (bwdUsage / 1000000000.00))

        # Check Credit
        if @user.credit.credit_value != 0 && @user.credit.credit_value > totalPrice
          @user.credit.decrement! :credit_value, totalPrice
          @status = 'succeeded'
        else
          @status = 'failed'

          # Suspend Subscription
          @user.subscription.update(status: 2)
        end

        # Create transaction of this month
        @user.credit.transactions.create(
          description: "Delivery Appliance running in global: #{ApplicationController::FormatNumber.new(bwdUsage).formatHumanSize()}, and File Appliance in global: #{ApplicationController::FormatNumber.new(stgUsage).formatHumanSize()} (Source:#{Package.find(@user.subscription.package).name} [#{@user.subscription.name}])",
          transaction_type: 'Automatic Payment',
          amount: totalPrice,
          status: @status,
          monthly: @thisMonth
        )
      # Effect only with subscription type monthly
      elsif subscription.payment_type == 3

      end
		end
  end
end