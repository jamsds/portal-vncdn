class AccountController < ApplicationController
  before_action :authenticate_user!

  def detailUpdate
    if current_user.update(detail_params)
      redirect_back(fallback_location: root_path)
    else
      render 'detail'
    end
  end

  def billing
    @thisMonth = Date.today.strftime("%Y-%m")

    if current_user.credit.transactions.nil? || current_user.credit.transactions.where(monthly: @thisMonth, transaction_type: "Automatic Payment", status: "succeeded").present?
      @totalPrice = 0
      @threshold = 0
    elsif current_user.subscription.nil?
      @totalPrice = 0
      @threshold = 0
    else
      bwdPrice = current_user.subscription.bwd_price
      stgPrice = current_user.subscription.stg_price

      if current_user.bandwidths.where(monthly: @thisMonth).present?
        bwdUsage = current_user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage / 1000000.00
      else
        bwdUsage = 0
      end

      if current_user.storages.where(monthly: @thisMonth).present?
        stgUsage = current_user.storages.find_by(monthly: @thisMonth).storage_usage / 1000000.00
      else
        stgUsage = 0
      end

      totalPrice = (stgPrice * stgUsage) + (bwdPrice * bwdUsage)

      @totalPrice = totalPrice
      @threshold = (totalPrice/1000000.00) * 100
    end
  end

  def transaction
    @startDateOfThisMonth = Date.current.beginning_of_month.strftime("%B %d")
    @dateTodayOfThisMonth = Date.current.strftime("%d, %Y")
  end

  def passwordUpdate
    if params[:password] != params[:password_confirmation]
      flash[:confirm_notice] = "Error! Confirm password not match, please check again."
    end

    if current_user.valid_password?(params[:verify_password])
      current_user.update(password: params[:password], password_confirmation: params[:password_confirmation])
    else
      flash[:verify_notice] = "Error! Current password incorrect, please check again."
    end

    redirect_back(fallback_location: root_path)
  end

  def notificationsUpdate
    if current_user.notification.update(notification_params)
      redirect_back(fallback_location: root_path)
    else
      render 'notification'
    end
  end

  def subscription
    @thisMonth = Date.today.strftime("%Y-%m")
    @expired = (Date.today + (1.month + 14.days)).strftime("%d/%m/%Y")

    if current_user.bandwidths.find_by(monthly: @thisMonth).present?
      @bwdUsage = current_user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage * 1000.00
    else
      @bwdUsage = 0
    end

    if current_user.storages.find_by(monthly: @thisMonth).present?
      @stgUsage = current_user.storages.find_by(monthly: @thisMonth).storage_usage * 1000.00
    else
      @stgUsage = 0
    end

    if current_user.subscription.nil?
      @bwdPercent = 0
      @stgPercent = 0
    else
      @bwdPercent = (@bwdUsage/current_user.subscription.bwd_limit) * 100
      @stgPercent = (@stgUsage/current_user.subscription.stg_limit) * 100
    end
  end

  def subscriptionAdd
    @package = Package.first

    if subscription_params["payment_type"] == "1"
      @expiration_date = Date.today + 14.days
    else
      @expiration_date = Date.today + (1.months + 14.days)
    end

    if current_user.parent_uuid.present?
      @reseller = subscription_params["reseller"]
    end

    current_user.create_subscription(
      name: subscription_params["name"],
      package: @package.id,
      payment_type: subscription_params["payment_type"],
      bwd_limit: @package.bwd_limit,
      stg_limit: @package.stg_limit,
      reseller: @reseller,
      expiration_date: @expiration_date
    )

    redirect_back(fallback_location: root_path)
  end

  def paymentCharge
  end

  def paymentVerify
    token = Stripe::Token.create(
      card: {
        name: params[:name],
        number: params[:number],
        exp_month: params[:exp_month],
        exp_year: params[:exp_year],
        cvc: params[:cvc],
      },
    )

    if current_user.credit.stripe_token.nil?
      customer = Stripe::Customer.create(
        :email => "#{current_user.email}",
        :description => "#{current_user.username}",
        :source => token
      )

      customer["sources"].each do |customer|
        @card_name = customer["name"]
        @card_token = customer["id"]
        @card_brand = customer["brand"]
        @exp_month = customer["exp_month"]
        @exp_year = customer["exp_year"]
        @last4 = customer["last4"]
        @funding = customer["funding"]
      end

      @update = current_user.credit.update(stripe_token: customer["id"], card_name: @card_name, card_token: @card_token, card_brand: @card_brand, expires: "#{@exp_month}/#{@exp_year}", last4: @last4, funding: @funding)
    else
      customer = Stripe::Customer.retrieve("#{current_user.credit.stripe_token}")
      created = customer.sources.create(source: token)

      @update = current_user.credit.update(card_name: created["name"], card_token: created["id"], card_brand: created["brand"], expires: "#{created["exp_month"]}/#{created["exp_year"]}", last4: created["last4"], funding: created["funding"])
    end

    if @update
      redirect_to account_payment_path
    end
  rescue Stripe::CardError => e
    flash[:verify_error] = e.message
    redirect_to account_payment_path
  end

  def paymentRemove
    customer = Stripe::Customer.retrieve("#{current_user.credit.stripe_token}")
    deleted = customer.sources.retrieve("#{current_user.credit.card_token}").delete

    @update = current_user.credit.update(card_name: nil, card_token: nil, card_brand: nil, expires: nil, last4: nil, funding: nil)
    
    if @update
      redirect_to account_payment_path
    end
  end

  def depositCharge
    if params[:amount].to_i < 500000
      flash[:verify_error] = "Deposit minimum is #{ApplicationController::FormatNumber.new(500000).formatPricing()}"
      redirect_to account_billing_deposit_path
    else
      if params[:type].nil?
        charge = Stripe::Charge.create(
          :amount => params[:amount].to_i,
          :currency => "vnd",
          :customer => current_user.credit.stripe_token,
          :source => current_user.credit.card_token,
          :description => "Deposit Credit Balance for account #{current_user.uuid}"
        )

        if charge["status"] == "succeeded"
          # increse credit balance
          current_user.credit.increment! :credit_value, params[:amount].to_i

          # create transaction
          current_user.credit.transactions.create(
            description: "Deposit Credit Balance for account #{current_user.uuid}",
            transaction_type: 'Deposit',
            stripe_id: current_user.credit.stripe_token,
            amount: params[:amount].to_i,
            card_id: current_user.credit.card_token,
            card_name: current_user.credit.card_name,
            card_number: current_user.credit.last4,
            card_brand: current_user.credit.card_brand,
            status: charge["status"],
            monthly: Date.current.strftime("%Y-%m")
          )

          redirect_to account_billing_path
        else
          flash[:verify_error] = "Can't process with this card, please check again."
          redirect_to account_payment_path
        end
      end
    end
  rescue TypeError => e
    flash[:verify_error] = e.message
    redirect_to account_billing_deposit_path
  rescue Stripe::InvalidRequestError => e
    flash[:verify_error] = e.message
    redirect_to account_billing_deposit_path
  rescue Stripe::CardError => e
    flash[:verify_error] = e.message

    # create transaction failed
    current_user.credit.transactions.create(
      description: "Deposit Credit Balance for account #{current_user.uuid}",
      transaction_error: e.message,
      transaction_type: 'Deposit',
      amount: params[:amount].to_i,
      card_id: current_user.credit.card_token,
      card_name: current_user.credit.card_name,
      card_number: current_user.credit.last4,
      card_brand: current_user.credit.card_brand,
      status: 'failed',
      monthly: Date.current.strftime("%Y-%m")
    )

    redirect_to account_payment_path
  end

  private
  	def detail_params
  		params.require(:user).permit(:name, :phone, :company)
  	end

    def notification_params
      params.require(:notification).permit(:notify_transaction, :notify_credit, :notify_subscription, :notify_invoice, :notify_product)
    end

    def subscription_params
      params.require(:subscription).permit(:name, :payment_type, :reseller)
    end
end