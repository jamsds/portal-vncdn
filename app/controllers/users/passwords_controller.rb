class Users::PasswordsController < Devise::PasswordsController
	def create
    domain = request.host
    @user = User.send_reset_password_instructions(params[:user].merge(domain: domain))

    if successfully_sent?(@user)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(:user))
    else
      respond_with(@user)
    end
  end
end