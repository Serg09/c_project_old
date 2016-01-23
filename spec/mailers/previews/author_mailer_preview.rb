# Preview all emails at http://localhost:3000/rails/mailers/author_mailer
class AuthorMailerPreview < ActionMailer::Preview
  def new_author_notification
    author = Author.pending.first || FactoryGirl.create(:author, status: Author.PENDING)
    AuthorMailer.new_author_notification(author)
  end

  def account_pending_notification
    author = Author.pending.first || FactoryGirl.create(:author, status: Author.PENDING)
    AuthorMailer.account_pending_notification(author)
  end

  def account_approved_notification
    author = Author.accepted.first || FactoryGirl.create(:author, status: Author.ACCEPTED)
    AuthorMailer.account_approved_notification(author)
  end

  def account_rejected_notification
    author = Author.rejected.first || FactoryGirl.create(:author, status: Author.REJECTED)
    AuthorMailer.account_rejected_notification(author)
  end
end
