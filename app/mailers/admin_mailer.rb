class AdminMailer < ApplicationMailer
  default to: 'info@crowdscribed.com'

  def bio_submission(bio)
    inline_images
    @bio = bio
    mail subject: "New bio submission"
  end

  def book_submission(book_version)
    inline_images
    @book_version = book_version
    mail subject: "New book submission"
  end

  def book_edit_submission(book_version)
    inline_images
    @book_version = book_version
    mail subject: "Book edit submission"
  end

  def campaign_succeeded(campaign)
    inline_images
    @campaign = campaign
    subject = "The campaign for #{@campaign.book.administrative_title} has reached its goal!"
    mail subject: subject
  end

  def campaign_progress(campaigns)
    inline_images
    @campaigns = campaigns
    mail subject: 'Campaign progress'
  end

  def contribution_received(contribution)
    inline_images
    @contribution = contribution
    @book = @contribution.campaign.book
    @author = @book.author
    mail subject: 'Contribution Received!'
  end

  def inquiry_received(inquiry)
    inline_images
    @inquiry = inquiry
    mail subject: "Crowdscribed inquiry #{('%06d' % inquiry.id)}"
  end

  def new_user(user)
    inline_images
    @user = user
    mail subject: 'New user'
  end
end
