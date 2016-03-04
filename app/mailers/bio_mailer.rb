class BioMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def submission(bio)
    inline_images
    @bio = bio
    mail to: "info@crowdscribed.com", subject: "New bio submission"
  end

  def approval(bio)
    inline_images
    @bio = bio
    mail to: bio.author.email, subject: 'Bio approved!'
  end

  def rejection(bio)
    inline_images
    @bio = bio
    mail to: bio.author.email, subject: 'Bio rejected'
  end
end
