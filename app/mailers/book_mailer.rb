class BookMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def submission(book)
    inline_images
    @book = book
    mail to: "info@crowdscribed.com", subject: "New book submission"
  end
end
