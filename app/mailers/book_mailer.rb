class BookMailer < ApplicationMailer
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
