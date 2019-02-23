require 'sidekiq-scheduler'

class ChargeMonthly
  include Sidekiq::Worker

  ## Run on first day of the month, it mean we need find data on previous month to make payment
  def perform
    @previousMonth = (Date.today - 1.months).strftime("%Y-%m")

  	# Only exec with subscription status is active
		Subscription.where(status: 1).each do |subscription|

			# Find user
			@user = User.find(subscription.user_id)

      # Get bandwidth & storage usage on previous month
      if @user.bandwidths.present?
        bwdUsage = @user.bandwidths.find_by(monthly: @previousMonth).bandwidth_usage * 1000.00
      else
        bwdUsage = 0
      end

      if @user.storages.present?
        stgUsage = @user.storages.find_by(monthly: @previousMonth).storage_usage * 1000.00
      else
        stgUsage = 0
      end

      # Calculator usage pricing
      @totalPrice = (@user.subscription.stg_price * (stgUsage / 1000000000.00)) + (@user.subscription.bwd_price * (bwdUsage / 1000000000.00))

      @description = "Delivery Appliance running in global: #{ApplicationController::FormatNumber.new(bwdUsage).formatHumanSize()}, and File Appliance in global: #{ApplicationController::FormatNumber.new(stgUsage).formatHumanSize()} (Source:#{Package.find(@user.subscription.package).name} [#{@user.subscription.name}])"
			
      if @totalPrice != 0
        # Effect only with subscription type automatic payment by credit card
        if @user.subscription.payment_type == 2 && @user.credit.card_token.present?
          charge = Stripe::Charge.create(
            :amount => @totalPrice.to_i,
            :currency => "vnd",
            :customer => @user.credit.stripe_token,
            :source => @user.credit.card_token,
            :description => @description
          )

          # Defind charge succeeded response from Stripe
          if charge["status"] == "succeeded"

            # Create transaction succeeded
            @user.credit.transactions.create(
              description: @description,
              transaction_type: 'Automatic Payment',
              stripe_id: charge["id"],
              amount: @totalPrice.to_i,
              card_id: @user.credit.card_token,
              card_name: @user.credit.card_name,
              card_number: @user.credit.last4,
              card_brand: @user.credit.card_brand,
              status: 'succeeded',
              monthly: @previousMonth
            )
          end
        end

        # Effect only with subscription type automatic payment by deposit
        if @user.subscription.payment_type == 2 && @user.credit.card_token.nil?

          # Check credit
          if @user.credit.credit_value != 0 && @user.credit.credit_value > @totalPrice

            # Update credit balance
            @user.credit.decrement! :credit_value, @totalPrice
            @status = 'succeeded'
          else
            @status = 'failed'

            # Suspend subscription if payment failed
            @user.subscription.update(status: 2)
          end

          # Create transaction of this month
          @user.credit.transactions.create(
            description: @description,
            transaction_type: 'Automatic Payment',
            amount: @totalPrice,
            status: @status,
            monthly: @previousMonth
          )
        end
      end
		end

    # Rescue error and create transaction failed with message
    rescue Stripe::CardError => e

      # Create transaction failed
      @user.credit.transactions.create(
        description: e.message,
        transaction_type: 'Automatic Payment',
        amount: @totalPrice.to_i,
        card_id: @user.credit.card_token,
        card_name: @user.credit.card_name,
        card_number: @user.credit.last4,
        card_brand: @user.credit.card_brand,
        status: 'failed',
        monthly: @previousMonth
      )

      # Suspend subscription if payment failed
      @user.subscription.update(status: 2)
  end
end