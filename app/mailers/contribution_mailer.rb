class ContributionMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  # Sends an email receipt to the donor
  def contribution_receipt(contribution)
    inline_images
    @contribution = contribution
    @book = @contribution.campaign.book
    @author = @book.author
    mail to: contribution.email, subject: 'Contribution receipt'
  end

  # Notifies the author of the book receiving the contribution
  # the the contribution has been received
  def contribution_received_notify_author(contribution)
    inline_images
    @contribution = contribution
    @book = @contribution.campaign.book
    @unsubscribe_url = unsubscribe_url(@book.author.unsubscribe_token)
    mail to: @book.author.email, subject: 'Contribution Received!'
  end
end
