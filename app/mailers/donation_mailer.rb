class DonationMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  # Sends an email receipt to the donor
  def donation_receipt(donation)
    inline_images
    @donation = donation
    @book = @donation.campaign.book
    @author = @book.author
    mail to: donation.email, subject: 'Donation receipt'
  end

  # Notifies the author of the book receiving the donation
  # the the donation has been received
  def donation_received_notify_author(donation)
    inline_images
    @donation = donation
    @book = @donation.campaign.book
    mail to: @book.author.email, subject: 'Donation Received!'
  end
end
