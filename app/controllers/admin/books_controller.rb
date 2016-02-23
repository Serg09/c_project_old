class Admin::BooksController < ApplicationController
  before_filter :safe_authenticate_administrator!
  before_filter :load_book, only: [:show, :approve, :reject]
  before_filter :load_author, only: [:new, :create]
  respond_to :html
  layout 'admin'

  def index
    @books = books_by_status.paginate(page: params[:page])
  end

  def show
    authorize! :show, @book
  end

  def approve
    authorize! :approve, @book
    if @book.approve
      BookMailer.approval(@book).deliver_now
      redirect_to admin_books_path, notice: 'The book has been approved successfully.'
    else
      render :show
    end
  end

  def reject
    authorize! :reject, @book
    if @book.reject
      BookMailer.rejection(@book).deliver_now
      redirect_to admin_books_path, notice: 'The book has been rejected successfully.'
    else
      render :show
    end
  end

  private

  def books_by_status
    Book.where(status: params[:status] || :pending)
  end

  def load_book
    @book = Book.find(params[:id])
    @book_version = @book.pending_version || @book.approved_version || @book.rejected_version
  end
end
