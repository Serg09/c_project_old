class InquiriesController < ApplicationController
  before_filter :load_inquiry, only: [:show, :archive]
  respond_to :html

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new inquiry_params
    if @inquiry.save
      flash[:notice] = 'Your inquiry has been accepted.'
      InquiryMailer.submission_notification(@inquiry).deliver_now
    else
      flash[:alert] = 'We were unable to accept your inquiry.'
    end
    respond_with @inquiry, location: pages_books_path
  end

  def archive
    authorize! :update, @inquiry
    @inquiry.archived = true
    flash[:notice] = 'The inquiry was archived successfully.' if @inquiry.save
    respond_with @inquiry, location: inquiries_path
  end

  def index
    authorize! :index, Inquiry
    @inquiries = Inquiry.all
    respond_with @inquiries do |format|
      format.html { render layout: 'admin' }
    end
  end

  def show
    authorize! :show, @inquiry
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:first_name, :last_name, :email, :body)
  end

  def load_inquiry
    @inquiry = Inquiry.find(params[:id])
  end
end
