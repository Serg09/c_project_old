class BioMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def approval(bio)
    @bio = bio
    @unsubscribe_url = unsubscribe_url(@bio.author.unsubscribe_token)
    mail to: bio.author.email, subject: 'Bio approved!'
  end

  def rejection(bio)
    @bio = bio
    @unsubscribe_url = unsubscribe_url(@bio.author.unsubscribe_token)
    mail to: bio.author.email, subject: 'Bio rejected'
  end
end
