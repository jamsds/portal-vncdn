# frozen_string_literal: true

if defined?(ActionMailer)
  class Devise::Mailer < Devise.parent_mailer.constantize
    include Devise::Mailers::Helpers

    def confirmation_instructions(record, token, opts={})
      @token = token
      @host = Thread.current[:request_host]

      if User.find_by(domain: @host).present?
        @color = User.find_by(domain: @host).color
        @logo = User.find_by(domain: @host).logo
      else
        @color = "#f68100"
        @logo = "http://<%= @host %>/assets/logo_dark.png"
      end

      devise_mail(record, :confirmation_instructions, opts)
    end

    def reset_password_instructions(record, token, opts={})
      @token = token
      @host = Thread.current[:request_host]

      if User.find_by(domain: @host).present?
        @color = User.find_by(domain: @host).color
        @logo = User.find_by(domain: @host).logo
      else
        @color = "#f68100"
        @logo = "http://reseller.vncdn.vn/assets/logo_dark.png"
      end

      devise_mail(record, :reset_password_instructions, opts)
    end

    def unlock_instructions(record, token, opts={})
      @token = token
      @host = Thread.current[:request_host]

      if User.find_by(domain: @host).present?
        @color = User.find_by(domain: @host).color
        @logo = User.find_by(domain: @host).logo
      else
        @color = "#f68100"
        @logo = "http://reseller.vncdn.vn/assets/logo_dark.png"
      end

      devise_mail(record, :unlock_instructions, opts)
    end

    def email_changed(record, opts={})
      @host = Thread.current[:request_host]

      if User.find_by(domain: @host).present?
        @color = User.find_by(domain: @host).color
        @logo = User.find_by(domain: @host).logo
      else
        @color = "#f68100"
        @logo = "http://reseller.vncdn.vn/assets/logo_dark.png"
      end

      devise_mail(record, :email_changed, opts)
    end

    def password_change(record, opts={})
      @host = Thread.current[:request_host]

      if User.find_by(domain: @host).present?
        @color = User.find_by(domain: @host).color
        @logo = User.find_by(domain: @host).logo
      else
        @color = "#f68100"
        @logo = "http://reseller.vncdn.vn/assets/logo_dark.png"
      end

      devise_mail(record, :password_change, opts)
    end
  end
end