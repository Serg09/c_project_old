class SubscriberMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def confirmation(subscriber)
    @subscriber = subscriber
    @contact_name = 'Josh Linton'
    @contact_title = 'Vice President of Sales and Marketing'
    @contact_email = 'josh.linton@crowdscribed.com'
    mail to: subscriber.email, subject: 'Welcome to Crowdscribed!'
  end
end
