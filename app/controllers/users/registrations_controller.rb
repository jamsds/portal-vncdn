class Users::RegistrationsController < Devise::RegistrationsController
	layout 'signin'
	
	private
   	def sign_up_params
     	params.require(:user).permit(:name, :username, :email, :uuid, :parent_uuid, :password, :password_confirmation) if params[:user].present?
   	end

		def after_inactive_sign_up_path_for(resource)
			new_user_confirmation_path
		end
end