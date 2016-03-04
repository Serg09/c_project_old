# Preview all emails at http://localhost:3000/rails/mailers/author_mailer
class AuthorMailerPreview < ActionMailer::Preview
  def new_author_notification
    author = Author.pending.first || FactoryGirl.create(:pending_author)
    AuthorMailer.new_author_notification(author)
  end

  def account_pending_notification
    author = Author.pending.first || FactoryGirl.create(:pending_author)
    AuthorMailer.account_pending_notification(author)
  end

  def account_approved_notification
    author = Author.approved.first || FactoryGirl.create(:approved_author)
    AuthorMailer.account_approved_notification(author)
  end

  def account_rejected_notification
    author = Author.rejected.first || FactoryGirl.create(:rejected_author)
    AuthorMailer.account_rejected_notification(author)
  end
end
