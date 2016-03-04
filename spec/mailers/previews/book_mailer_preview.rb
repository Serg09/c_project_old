# Preview all emails at http://localhost:3000/rails/mailers/books
class BookMailerPreview < ActionMailer::Preview

  def submission
    BookMailer.submission Book.pending.first || FactoryGirl.create(:pending_book)
  end

  def edit_submission
    BookMailer.edit_submission Book.pending.first || FactoryGirl.create(:pending_book)
  end

  def approval
    BookMailer.submission Book.approved.first || FactoryGirl.create(:approved_book)
  end

  def rejection
    BookMailer.rejection Book.rejected.first || FactoryGirl.create(:rejected_book)
  end
end
