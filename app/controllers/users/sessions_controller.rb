class Users::SessionsController < Devise::SessionsController
	def create
		@user = User.find_by(email: sign_in_params["email"]).parent_uuid
		@parent_uuid = User.find_by(username: @user).domain

		if @parent_uuid == request.host
 			self.resource = warden.authenticate!(auth_options)
 			set_flash_message!(:notice, :signed_in)
	    sign_in(resource_name, resource)
	    yield resource if block_given?
			respond_with resource, location: after_sign_in_path_for(resource)
 		else
 			reset_session
    	flash[:verify_notice] = "Found this user in our system. But you not belong to this reseller. Please check with your reseller and login again."
			redirect_back(fallback_location: root_path)
    end
  end

  private
   	def sign_in_params
     	params.require(:user).permit(:email, :password, :remember_me) if params[:user].present?
   	end
end