class InquiriesController < ApplicationController
  respond_to :html

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new inquiry_params
    flash[:notice] = 'Your inquiry has been accepted.' if @inquiry.save
    respond_with @inquiry, location: pages_books_path
  end

  def edit
  end

  def update
  end

  def index
  end

  def show
  end

  def destroy
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:first_name, :last_name, :email, :body)
  end
end
