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
    if current_user.update(password_params)
      redirect_back(fallback_location: root_path)
    else
      render 'password'
    end
  end

  private
  	def detail_params
  		params.require(:user).permit(:name, :phone, :company)
  	end

    def password_params
  		params.require(:user).permit(:password, :password_confirmation)
  	end
end