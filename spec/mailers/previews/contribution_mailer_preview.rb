# Preview all emails at http://localhost:3000/rails/mailers/contribution_mailer
class ContributionMailerPreview < ActionMailer::Preview
  def contribution_receipt
    contribution = Contribution.first || FactoryGirl.create(:contribution)
    ContributionMailer.contribution_receipt(contribution)
  end

  def contribution_received_notify_author
    contribution = Contribution.first || FactoryGirl.create(:contribution)
    ContributionMailer.contribution_received_notify_author(contribution)
  end
end
