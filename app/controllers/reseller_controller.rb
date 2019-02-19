class ResellerController < ApplicationController
  before_action :authenticate_user!

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

  private
    def customer_detail_params
      params.require(:user).permit(:username, :name, :phone, :company)
    end

    def customer_params
      params.require(:user).permit(:name, :username, :email, :parent_uuid, :password, :password_confirmation)
    end
end