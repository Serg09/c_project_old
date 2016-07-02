# Preview all emails at http://localhost:3000/rails/mailers/subscriber_mailer
class SubscriberMailerPreview < ActionMailer::Preview
  def confirmation
    subscriber = Subscriber.first || FactoryGirl.create(:subscriber)
    SubscriberMailer.confirmation subscriber
  end
end
