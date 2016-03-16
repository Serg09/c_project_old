# Preview all emails at http://localhost:3000/rails/mailers/donation_mailer
class DonationMailerPreview < ActionMailer::Preview
  def donation_receipt
    donation = Donation.first || FactoryGirl.create(:donation)
    DonationMailer.donation_receipt(donation)
  end

  def donation_received_notify_author
    donation = Donation.first || FactoryGirl.create(:donation)
    DonationMailer.donation_received_notify_author(donation)
  end

  def donation_received_notify_administrator
    donation = Donation.first || FactoryGirl.create(:donation)
    DonationMailer.donation_received_notify_administrator(donation)
  end
end
