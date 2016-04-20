class FulfillmentsController < ApplicationController
  before_filter :authenticate_author!

  def index
    @fulfillments = Fulfillment.
      author(current_author).
      undelivered.
      ready.
      paginate(page: params[:page])
  end
end
