class Admin::FulfillmentsController < ApplicationController
  before_filter :safe_authenticate_administrator!

  layout 'admin'
  respond_to :html

  def index
    @fulfillments = Fulfillment.undelivered.house.ready
  end
end
