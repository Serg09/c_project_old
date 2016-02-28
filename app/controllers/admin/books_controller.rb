class Admin::BooksController < ApplicationController
  before_filter :safe_authenticate_administrator!
  respond_to :html
  layout 'admin'

  def index
    @books = books_by_status.paginate(page: params[:page])
  end

  private

  def books_by_status
    Book.where(status: params[:status] || :pending)
  end
end
