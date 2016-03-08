class InquiriesController < ApplicationController
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
    respond_with @inquiry, location: browse_books_path
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:first_name, :last_name, :email, :body)
  end
end
