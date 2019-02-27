class NotificationMailer < ApplicationMailer
  default from: 'no-reply@vncdn.vn'
  layout 'mailer'

  class SetVariable
    def initialize(id)
      @id = id
    end

    def variableBuild
      @user = User.find(@id)

      if @user.parent_uuid.present? && User.find_by(username: @user.parent_uuid).domain.present?
        @host = User.find_by(username: @user.parent_uuid).domain
      else
        @host = 'reseller.vncdn.vn'
      end

      if @user.parent_uuid.present? && User.find_by(username: @user.parent_uuid).color.present?
        @color = User.find_by(username: @user.parent_uuid).color
      else
        @color = "#f68100"
      end

      if @user.parent_uuid.present? && User.find_by(username: @user.parent_uuid).company.present?
        @company = User.find_by(username: @user.parent_uuid).company
      else
        @company = "VNCDN"
      end

      if @user.parent_uuid.present? && User.find_by(username: @user.parent_uuid).logo.present?
        @company = User.find_by(username: @user.parent_uuid).logo
      else
        @company = "http://reseller.vncdn.vn/assets/logo_dark.png"
      end
    end
  end


  # Free Trial Subscription
  def trial_email(id)
    @user = User.find(id)

    @name = @user.name
    @email = @user.email

    SetVariable.new(id).variableBuild()

    @bwdLimit = @user.subscription.bwd_limit
    @stgLimit   = @user.subscription.stg_limit
    
    mail(
      to: @email,
      content_type: "text/html",
      subject: "VNCDN - Trial Subscription",
    )
  end

  def new_card_email(id)
    @user = User.find(id)

    @name = @user.name
    @email = @user.email

    SetVariable.new(id).variableBuild()

    @card_brand = @user.credit.card_brand
    @card_number = @user.credit.last4
    @expires = @user.credit.expires

    mail(
      to: @email,
      content_type: "text/html",
      subject: "VNCDN - Card Linked Notification",
    )
  end
end