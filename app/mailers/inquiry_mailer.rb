class InquiryMailer < ApplicationMailer
  default from: 'inquiries@crowdscribe.com'

  def submission_notification(inquiry)
    @inquiry = inquiry
    mail to: 'info@crowdscribed.com', subject: "Crowdscribe inquiry #{('%06d' % inquiry.id)}"
  end
end
