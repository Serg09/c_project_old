class BookMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def submission(book)
    inline_images
    @book = book
    mail to: "info@crowdscribed.com", subject: "New book submission"
  end

  def approval(book)
    inline_images
    @book = book
    mail to: book.author.email, subject: 'Your book has been approved!'
  end

  def rejection(book)
    inline_images
    @book = book
    mail to: book.author.email, subject: 'Your book has been rejected'
  end
end
