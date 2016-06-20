# Preview all emails at http://localhost:3000/rails/mailers/admin
class AdminMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/bios/submission
  def bio_submission
    bio = Bio.pending.first || FactoryGirl.create(:bio)
    AdminMailer.bio_submission bio
  end

  def book_submission
    book_version = BookVersion.pending.first || FactoryGirl.create(:pending_book_version)
    AdminMailer.book_submission book_version
  end

  def book_edit_submission
    book_version = BookVersion.pending.first || FactoryGirl.create(:pending_book_version)
    AdminMailer.book_edit_submission book_version
  end

  def campaign_progress
    AdminMailer.campaign_progress Campaign.active.by_target_date
  end

  def campaign_succeeded
    campaign = Campaign.cancelled.first || FactoryGirl.create(:cancelled_campaign)
    AdminMailer.campaign_succeeded(campaign)
  end

  def contribution_received
    contribution = Contribution.first || FactoryGirl.create(:contribution)
    AdminMailer.contribution_received(contribution)
  end

  def inquiry_received
    inquiry = Inquiry.active.first || FactoryGirl.create(:inquiry)
    AdminMailer.inquiry_received(inquiry)
  end

  def new_user
    user = User.pending.first || FactoryGirl.create(:pending_user)
    AdminMailer.new_user(user)
  end
end
