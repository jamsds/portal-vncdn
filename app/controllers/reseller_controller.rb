class ResellerController < ApplicationController
  before_action :authenticate_user!

  before_action :authenticate_reseller

  # Set Request Method
  before_action :post_method, only: [:customerAdd]
  before_action :delete_method, only: [:customerDelete]

  # Set End Point Request
	before_action :base_endpoint, only: [:customerAdd, :customerDelete]

  def index
    @customers = User.where(parent_uuid: current_user.username)
  end

  def customer
  	@customers = User.where(parent_uuid: current_user.username)
  end

  def customerDetail
  	@customer = User.find_by(username: params[:username])
  end

  def customerEdit
    @customer = User.find_by(username: params[:username])
  end

  def customerBilling
    @customer = User.find_by(username: params[:username])

    if @customer.credit.nil?
      @credit = 0
    else
      @credit = @customer.credit.credit_value
    end
  end

  def customerTransactions
    @customer = User.find_by(username: params[:username])

    @previousMonthWithYear = (Date.today - 1.month).strftime("%B %Y")
    @previousMonth = (Date.today - 1.month).strftime("%Y-%m")

    @thisMonth = Date.today.strftime("%Y-%m")

    @startDateOfThisMonth = Date.current.beginning_of_month.strftime("%B %d")
    @dateTodayOfThisMonth = Date.current.strftime("%d, %Y")
  end

  def customerAdd
  	@customer = User.new(customer_params)
		@uuid = customer_params["username"]

    if customer_params["password"] != customer_params["password_confirmation"]
      flash[:confirm_notice] = "Error! Confirm password not match, please check again."
      redirect_back(fallback_location: root_path)
    end

		if @customer.save
			@requestURI = "/v1.1/createCustomer/"
			@requestBody = "{\"name\":\"#{@uuid}\",\"parentId\":#{$ROOT_ID},\"type\":2,\"partnership\":1}"
			@response = JSON.parse(RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest())

			@latest = User.find_by(username: @uuid)

			@latest.update(uuid: @response["id"])

      Credit.create(user_id: @latest.id)
      Notification.create(user_id: @latest.id)

      redirect_to reseller_customer_path
		end
  end

  def customerUpdate
    @customer = User.find_by(username: customer_detail_params["username"])

    @customer.update(name: customer_detail_params["name"], phone: customer_detail_params["phone"], company: customer_detail_params["company"])
    redirect_back(fallback_location: root_path)
  end

  def customerDelete
    @customer = User.find_by(username: params[:username])

    if @customer.destroy
      @requestURI = "/v1.1/deleteCustomer/#{@customer.uuid}"
      RestAPI.new("#{@requestURI}", "#{@requestBody}").openRequest()
    end

    redirect_back(fallback_location: root_path)
  end

  def package
    @packages = Package.where(reseller: current_user.username)
  end

  def packageAdd
    @package = Package.new(package_params)
 
    if @package.save
      redirect_to reseller_package_path
    else
      render 'packageCreate'
    end
  end

  def subscription
    @subscriptions = Subscription.where(reseller: current_user.username)
  end

  def resellerUpdate
    if portal_params["domain"] == "reseller.vncdn.vn"
      flash[:verify_notice] = "Domain unavailable for use. Please check and use another domain."
      redirect_back(fallback_location: reseller_path)
    else
      if current_user.update(portal_params)
        flash[:success] = "This record has been updated successfully"
        redirect_back(fallback_location: reseller_path)
      else
        flash[:danger] = "Error! Please check again"
        render 'account'
      end
    end
  end

  private
    def authenticate_reseller
      if current_user.accountType != 2
        redirect_to root_url
      end
    end

    def customer_detail_params
      params.require(:user).permit(:username, :name, :phone, :company)
    end

    def customer_params
      params.require(:user).permit(:name, :username, :email, :parent_uuid, :password, :password_confirmation)
    end

    def package_params
      params.require(:package).permit(:name, :bwd_limit, :stg_limit, :bwd_price, :stg_price, :bwd_price_over, :stg_price_over, :reseller, :pricing)
    end

    def portal_params
      params.require(:user).permit(:domain, :logo, :color, :attachment_delete)
    end
end