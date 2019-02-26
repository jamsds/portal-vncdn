class Users::SessionsController < Devise::SessionsController
	def create
		# Verify user reseller owner
		if User.find_by(email: sign_in_params["email"]).accountType == 1 && User.find_by(email: sign_in_params["email"]).parent_uuid.present?
			@parent = User.find_by(email: sign_in_params["email"]).parent_uuid
			@parent_uuid = User.find_by(username: @parent)
		elsif User.find_by(email: sign_in_params["email"]).accountType == 2
			@parent_uuid = User.find_by(email: sign_in_params["email"])
		end

		if @parent_uuid.domain == request.host
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