class ApplicationMailer < ActionMailer::Base
  default from: "info@crowdscribe.com"
  layout 'mailer'

  protected

  def inline_images
    attachments.inline['logo.png'] = File.read('app/assets/images/crowdscribed_logo.png')
  end
end
