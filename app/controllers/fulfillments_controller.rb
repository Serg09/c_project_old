class FulfillmentsController < ApplicationController
  before_filter :authenticate_author!
  before_filter :load_fulfillment, only: :fulfill

  def index
    @fulfillments = Fulfillment.
      author(current_author).
      undelivered.
      ready.
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
