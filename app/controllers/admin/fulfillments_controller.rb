class Admin::FulfillmentsController < ApplicationController
  before_filter :safe_authenticate_administrator!

  layout 'admin'
  respond_to :html

  def index
    @fulfillments = Fulfillment.
      undelivered.
      house.
      ready.
      paginate(page: params[:page])
    respond_with @fulfillments
  end
end
