class UserMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def new_user_notification(user)
    inline_images
    @user = user
    mail to: 'info@crowdscribed.com', subject: 'New user'
  end

  def account_pending_notification(user)
    inline_images
    @user = user
    mail to: user.email, subject: 'Approval pending'
  end

  def account_approved_notification(user)
    inline_images
    @user = user
    mail to: user.email, subject: 'Account approved'
  end

  def account_rejected_notification(user)
    inline_images
    @user = user
    mail to: user.email, subject: 'Account rejected'
  end
end
