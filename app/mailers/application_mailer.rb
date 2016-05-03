class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@crowdscribed.com'
  layout 'mailer'

  protected

  def inline_images
    attachments.inline['logo.png'] = File.read('app/assets/images/crowdscribed_logo.png')
  end
end
