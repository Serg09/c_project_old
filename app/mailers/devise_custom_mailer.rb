class DeviseCustomMailer < Devise::Mailer
  before_filter :inline_images
  layout 'mailer'

  protected

  def inline_images
    attachments.inline['logo.png'] = File.read('app/assets/images/crowdscribed_logo.png')
  end
end
