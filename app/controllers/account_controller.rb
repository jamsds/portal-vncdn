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
    if current_user.valid_password?(params[:verify_password])
      current_user.update(password: params[:password], password_confirmation: params[:password_confirmation])
    else
      flash[:verify_notice] = "Error! Current password incorrect, please check again."
    end

    redirect_back(fallback_location: root_path)
  end

  private
  	def detail_params
  		params.require(:user).permit(:name, :phone, :company)
  	end
end