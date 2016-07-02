class SubscribersController < ApplicationController
  respond_to :html

  def new
    @subscriber = Subscriber.new
  end

  def create
    @subscriber = Subscriber.new subscriber_params
    if @subscriber.save
      flash[:notice] = 'You have signed up successfully.'
      cookies[:subscribed] = { value: '1', expires: 1.week.from_now }
      SubscriberMailer.confirmation(@subscriber).deliver_now
    end
    respond_with @subscriber
  end

  def show
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:first_name, :last_name, :email)
  end
end
