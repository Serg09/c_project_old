class AuthorMailer < ApplicationMailer
  default from: 'accounts@crowdscribe.com'

  def account_pending_notification(author)
    @author = author
    mail to: author.email, subject: 'Approval pending'
  end

  def account_approved_notification(author)
    @author = author
    mail to: author.email, subject: 'Account approved'
  end
end
