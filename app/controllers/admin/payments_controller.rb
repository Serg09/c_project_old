class Admin::PaymentsController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_payment, only: [:show, :refresh, :refund]
  layout 'admin'

  def index
    @status = params[:status] || 'pending'
    @payments = Payment.
      where(state: @status).
      order('created_at desc').
      paginate(page: params[:page])
  end

  def show
    if params[:status].present? || @payment.contribution.nil?
      @back_path = admin_payments_path(status: params[:status])
      @back_tool_tip = 'Click here to return to the list of payments.'
    else
      @back_path = admin_campaign_path(@payment.contribution.campaign_id)
      @back_tool_tip = 'Click here to return to the campaign page.'
    end
  end

  def refresh
    @payment.complete!
    redirect_to admin_payments_path(status: @payment.state)
  end

  def refund
    if @payment.refund!
      flash[:notice] = 'The payment was refunded successfully.'
    else
      flash[:alert] = 'Unable to refund the payment.'
    end
    redirect_to admin_payments_path(status: @payment.state)
  end

  private

  def load_payment
    @payment = Payment.find(params[:id])
  end
end
