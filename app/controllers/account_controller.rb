class AccountController < ApplicationController
  before_action :authenticate_user!

  def index
		@user_child = User.where(parent_uuid: current_user.username)
  end

  def detailUpdate
    if current_user.update(detail_params)
      redirect_back(fallback_location: root_path)
    else
      render 'detail'
    end
  end

  def billing
    @thisMonth = Date.today.strftime("%Y-%m")

    bwdPrice = current_user.subscription.bwd_price
    stgPrice = current_user.subscription.stg_price

    if current_user.bandwidths.find_by(monthly: @thisMonth).nil?
      bwdUsage = 0
    else
      # usage value need to convert to GB, because pricing is price per GB
      bwdUsage = current_user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage / 1000000.00
    end

    if current_user.storages.find_by(monthly: @thisMonth).nil?
      stgUsage = 0
    else
      stgUsage = current_user.storages.find_by(monthly: @thisMonth).storage_usage / 1000000.00
    end

    totalCredit = current_user.credit.credit_value
    totalPrice = (stgPrice * stgUsage) + (bwdPrice * bwdUsage)

    @totalPrice = totalPrice
    @threshold = (totalPrice/totalCredit) * 100
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

    if current_user.bandwidths.find_by(monthly: @thisMonth).nil?
      @bwdUsage = 0
    else
      @bwdUsage = current_user.bandwidths.find_by(monthly: @thisMonth).bandwidth_usage * 1000.00
    end

    if current_user.storages.find_by(monthly: @thisMonth).nil?
      @stgUsage = 0
    else
      @stgUsage = current_user.storages.find_by(monthly: @thisMonth).storage_usage * 1000.00
    end

    @bwdPercent = (@bwdUsage/current_user.subscription.bwd_limit) * 100
    @stgPercent = (@stgUsage/current_user.subscription.stg_limit) * 100
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

    current_user.create_subscription(name: subscription_params["name"], package: @package.id, payment_type: subscription_params["payment_type"],bwd_limit: @package.bwd_limit, stg_limit: @package.stg_limit, reseller: @reseller, expiration_date: @expiration_date)
    redirect_back(fallback_location: root_path)
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