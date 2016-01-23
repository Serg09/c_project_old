class InquiryMailerPreview < ActionMailer::Preview
  def submission_notification
    inquiry = Inquiry.active.first || FactoryGirl.create(:inquiry)
    InquiryMailer.submission_notification(inquiry)
  end
end
