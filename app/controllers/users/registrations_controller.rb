class Users::RegistrationsController < Devise::RegistrationsController
	private
   	def sign_up_params
     	params.require(:user).permit(:name, :email, :uuid, :parent_uuid, :password, :password_confirmation) if params[:user].present?
   	end
end