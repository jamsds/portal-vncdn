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
    @expired = (Date.today + (1.month + 14.days)).strftime("%d/%m/%Y")
  end

  def subscriptionAdd
    @package = Package.first

    if subscription_params["payment_type"] == "1"
      @expiration_date = Date.today + 14.days
    else
      @expiration_date = Date.today + (1.months + 14.days)
    end

    current_user.create_subscription(name: subscription_params["name"], payment_type: subscription_params["payment_type"],bwd_limit: @package.bwd_limit, stg_limit: @package.stg_limit, expiration_date: @expiration_date)
  end

  private
  	def detail_params
  		params.require(:user).permit(:name, :phone, :company)
  	end

    def notification_params
      params.require(:notification).permit(:notify_transaction, :notify_credit, :notify_subscription, :notify_invoice, :notify_product)
    end

    def subscription_params
      params.require(:subscription).permit(:name, :payment_type)
    end
end