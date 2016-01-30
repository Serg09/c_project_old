class BioMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def submission(bio)
    inline_images
    @bio = bio
    mail to: "info@crowdscribed.com", subject: "New bio submission"
  end

  def approval
    inline_images
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def rejection
    inline_images
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
