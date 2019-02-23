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
      subject: "Free Trial Subscription",
    )
  end

  def new_card_email(id)
    @user = User.find(id)

    @name = @user.name
    @email = @user.email

    @card_brand = @user.credit.card_brand
    @card_number = @user.credit.last4

    mail(
      to: @email,
      content_type: "text/html",
      subject: "Credit Card Notifications",
    )
  end
end