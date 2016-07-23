class Admin::PaymentsController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_payment, only: [:show]
  layout 'admin'

  def index
    @payments = Payment.
      where(state: params[:status] || 'pending').
      order('created_at desc').
      paginate(page: params[:page])
  end

  def show
  end

  private

  def load_payment
    @payment = Payment.find(params[:id])
  end
end
