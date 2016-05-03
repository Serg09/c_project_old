class UserMailer < ApplicationMailer
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
