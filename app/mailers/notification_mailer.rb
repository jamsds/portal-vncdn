class NotificationMailer < ApplicationMailer
  default from: 'no-reply@vncdn.vn'
  layout 'mailer'

  # Free Trial Subscription
  def trial_email(id)
    @user = User.find(id)

    @name = @user.name
    @email = @user.email

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

    @domain = User.find_by(username: @user.parent_uuid).domain

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