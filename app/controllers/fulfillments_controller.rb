class FulfillmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_fulfillment, only: :fulfill

  def index
    @fulfillments = current_user.
      pending_fulfillments.
      paginate(page: params[:page])
  end

  def fulfill
    authorize! :fulfill, @fulfillment
    @fulfillment.delivered = true
    flash[:notice] = 'The reward was updated successfully.' if @fulfillment.save
    redirect_to fulfillments_path
  end

  private

  def load_fulfillment
    @fulfillment = Fulfillment.find(params[:id])
  end
end
