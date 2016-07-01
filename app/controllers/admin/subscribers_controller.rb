class Admin::SubscribersController < ApplicationController
  before_filter :authenticate_administrator!
  layout 'admin'

  def index
    @subscribers = Subscriber.paginate(page: params[:page])
  end
end
