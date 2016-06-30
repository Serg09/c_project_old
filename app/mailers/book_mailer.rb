class BookMailer < ApplicationMailer
  def approval(book_version)
    @book_version = book_version
    @unsubscribe_url = unsubscribe_url(@book_version.author.unsubscribe_token)
    mail to: book_version.book.author.email, subject: 'Your book has been approved!'
  end

  def rejection(book_version)
    @book_version = book_version
    @unsubscribe_url = unsubscribe_url(@book_version.author.unsubscribe_token)
    mail to: book_version.book.author.email, subject: 'Your book has been rejected'
  end
end
