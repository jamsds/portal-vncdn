# frozen_string_literal: true

if defined?(ActionMailer)
  class Devise::Mailer < Devise.parent_mailer.constantize
    before_action :set_variable_mailer
    
    include Devise::Mailers::Helpers

    def confirmation_instructions(record, token, opts={})
      @token = token
      devise_mail(record, :confirmation_instructions, opts)
    end

    def reset_password_instructions(record, token, opts={})
      @token = token
      devise_mail(record, :reset_password_instructions, opts)
    end

    def unlock_instructions(record, token, opts={})
      @token = token
      devise_mail(record, :unlock_instructions, opts)
    end

    def email_changed(record, opts={})
      devise_mail(record, :email_changed, opts)
    end

    def password_change(record, opts={})
      devise_mail(record, :password_change, opts)
    end

    private
      def set_variable_mailer
        @host = Thread.current[:request_host]

        if User.find_by(domain: @host).present? && User.find_by(domain: @host).color.present?
          @color = User.find_by(domain: @host).color
        else
          @color = "#f68100"
        end

        if User.find_by(domain: @host).present? && User.find_by(domain: @host).logo.present?
          @logo = User.find_by(domain: @host).logo
        else
          @logo = "http://reseller.vncdn.vn/assets/logo_dark.png"
        end
      end
  end
end