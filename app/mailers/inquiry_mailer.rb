class InquiryMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def submission_notification(inquiry)
    inline_images
    @inquiry = inquiry
    mail to: 'info@crowdscribed.com', subject: "Crowdscribe inquiry #{('%06d' % inquiry.id)}"
  end

  private

  def inline_images
    attachments.inline['logo.png'] = File.read('app/assets/images/crowdscribed_logo.png')
  end
end
