class Admin::PaymentsController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_payment
  layout 'admin'

  def show
  end

  private

  def load_payment
    @payment = Payment.find(params[:id])
  end
end
