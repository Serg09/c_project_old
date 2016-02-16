class BooksController < ApplicationController
  before_filter :load_book, only: [:show, :edit, :update, :approve, :reject]
  before_filter :load_author, only: [:new, :create]
  respond_to :html

  def index
    @author = Author.find(params[:author_id]) if params[:author_id].present?
    @books = administrator_signed_in? ?
      Book.all :
      @author.try(:books)
  end

  def show
    authorize! :show, @book
  end

  def new
    @book = Book.new author_id: @author.id
    authorize! :create, @book
  end

  def create
    @book = @author.books.new(book_params)
    authorize! :create, @book
    genres_from_params.each{|genre| @book.genres << genre}
    if @book.save
      flash[:notice] = 'Your book has been submitted successfully.'
      BookMailer.submission(@book).deliver_now
    end
    respond_with @book
  end

  def edit
    authorize! :update, @book
  end

  def update
    authorize! :update, @book
    @book.update_attributes book_params
    flash[:notice] = 'The book was updated successfully.' if @book.save
    respond_with @book
  end

  def approve
    authorize! :approve, @book
    @book.status = Book.APPROVED
    if @book.save
      BookMailer.approval(@book).deliver_now
      redirect_to books_path, notice: 'The book has been approved successfully.'
    else
      render :show
    end
  end

  def reject
    authorize! :reject, @book
    @book.status = Book.REJECTED
    if @book.save
      BookMailer.rejection(@book).deliver_now
      redirect_to books_path, notice: 'The book has been rejected successfully.'
    else
      render :show
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :short_description, :long_description, :cover_image_file)
  end

  def genres_from_params
    return [] unless params[:genres]
    params[:genres].map{|id| Genre.find(id)}
  end

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_book
    @book = Book.find(params[:id])
  end
end
