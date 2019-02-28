class Users::SessionsController < Devise::SessionsController
	layout 'signin'
	prepend_before_action :checkSSID, only: [:new]
	skip_before_action :verify_authenticity_token, only: [:destroy]

  private
  	def checkSSID
  		if cookies.signed["_ssid"].present? && User.where(email: cookies.signed["_ssid"]).size == 0
				@valid = false
			else
				@valid = true
			end

			if cookies.signed["_ssid"].present? && User.where(email: cookies.signed["_ssid"]).size != 0 && User.find_by(email: cookies.signed["_ssid"]).confirmed_at.nil?
				@confirmed = false
			else
				@confirmed = true
			end

			if cookies.signed["_ssid"].present?
				@user = User.find_by(email: cookies.signed["_ssid"])

				if @user.present? && @user.accountType == 1 && @user.parent_uuid.present?
					@parent = User.find_by(username: @user.parent_uuid)
					@domain = @parent.domain
				elsif @user.present? &&  @user.accountType == 1 && !@user.parent_uuid.present?
					@domain = 'reseller.vncdn.vn'
				elsif @user.present? &&  @user.accountType == 2 && @user.domain.present?
					@domain = @user.domain
				elsif @user.present? && @user.accountType == 2 && @user.domain.nil?
					@domain = 'reseller.vncdn.vn'
				end

				if @domain == request.host
					@permit = true
				else
					@permit = false
				end
			end
  	end
end