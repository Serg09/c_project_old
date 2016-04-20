class Admin::FulfillmentsController < ApplicationController
  before_filter :safe_authenticate_administrator!
  before_filter :load_fulfillment, only: :fulfill

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

  def fulfill
    @fulfillment.delivered = true
    flash[:notice] = 'The reward was updated successfully.' if @fulfillment.save
    redirect_to admin_fulfillments_path
  end

  private

  def load_fulfillment
    @fulfillment = Fulfillment.find(params[:id])
  end
end
