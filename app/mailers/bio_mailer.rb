class BioMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

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
