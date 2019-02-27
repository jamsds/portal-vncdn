class Users::ConfirmationsController < Devise::ConfirmationsController
	layout 'signin'

	before_action :clear_cookies

  private
  	def clear_cookies
  		cookies.signed["_ssid"] = nil
  	end
end