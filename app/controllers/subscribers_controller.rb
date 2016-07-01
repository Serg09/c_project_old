class SubscribersController < ApplicationController
  respond_to :html

  def new
  end

  def create
    @subscriber = Subscriber.new subscriber_params
    flash[:notice] = 'You have signed up successfully.' if @subscriber.save

    puts responder.inspect

    respond_with @subscriber
  end

  def show
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:first_name, :last_name, :email)
  end
end
