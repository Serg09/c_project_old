# Preview all emails at http://localhost:3000/rails/mailers/books
class BookMailerPreview < ActionMailer::Preview

  def approval
    BookMailer.approval BookVersion.approved.first || FactoryGirl.create(:approved_book_version)
  end

  def rejection
    BookMailer.rejection BookVersion.rejected.first || FactoryGirl.create(:rejected_book_version)
  end
end
