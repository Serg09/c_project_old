# Preview all emails at http://localhost:3000/rails/mailers/books
class BookMailerPreview < ActionMailer::Preview

  def approval
    BookMailer.submission Book.approved.first || FactoryGirl.create(:approved_book)
  end

  def rejection
    BookMailer.rejection Book.rejected.first || FactoryGirl.create(:rejected_book)
  end
end
