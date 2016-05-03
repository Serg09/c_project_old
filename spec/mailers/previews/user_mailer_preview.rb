# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def account_pending_notification
    user = User.pending.first || FactoryGirl.create(:pending_user)
    UserMailer.account_pending_notification(user)
  end

  def account_approved_notification
    user = User.approved.first || FactoryGirl.create(:approved_user)
    UserMailer.account_approved_notification(user)
  end

  def account_rejected_notification
    user = User.rejected.first || FactoryGirl.create(:rejected_user)
    UserMailer.account_rejected_notification(user)
  end
end
