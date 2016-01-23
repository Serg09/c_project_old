class AuthorMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def new_author_notification(author)
    inline_images
    @author = author
    mail to: 'info@crowdscribed.com', subject: 'New author'
  end

  def account_pending_notification(author)
    inline_images
    @author = author
    mail to: author.email, subject: 'Approval pending'
  end

  def account_approved_notification(author)
    inline_images
    @author = author
    mail to: author.email, subject: 'Account approved'
  end

  def account_rejected_notification(author)
    inline_images
    @author = author
    mail to: author.email, subject: 'Account rejected'
  end

  private

  def inline_images
    attachments.inline['logo.png'] = File.read('app/assets/images/crowdscribed_logo.png')
  end
end
