class BookMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def submission(book_version)
    inline_images
    @book_version = book_version
    mail to: "info@crowdscribed.com", subject: "New book submission"
  end

  def edit_submission(book_version)
    inline_images
    @book_version = book_version
    mail to: "info@crowdscribed.com", subject: "Book edit submission"
  end

  def approval(book_version)
    inline_images
    @book_version = book_version
    mail to: book_version.book.author.email, subject: 'Your book has been approved!'
  end

  def rejection(book_version)
    inline_images
    @book_version = book_version
    mail to: book_version.book.author.email, subject: 'Your book has been rejected'
  end
end
