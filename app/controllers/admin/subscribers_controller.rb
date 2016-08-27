require 'csv'

class Admin::SubscribersController < ApplicationController
  respond_to :html, :csv
  before_filter :authenticate_administrator!
  layout 'admin'

  def index
    @subscribers = Subscriber.all
    respond_to do |format|
      format.html do
        @subscribers = @subscribers.paginate(page: params[:page], per_page: 5)
      end
      format.csv do
        headers['Content-Disposition'] = 'attachment; filename="subscribers.csv"'
        headers['Content-Type'] = 'text/csv'
      end
    end
  end
end
