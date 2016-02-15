class BooksController < ApplicationController
  before_filter :load_book, only: [:show, :edit, :update]
  before_filter :load_author, only: [:create]
  respond_to :html

  def index
  end

  def show
    authorize! :show, @book
  end

  def new
  end

  def create
    @book = @author.books.new(book_params)
    flash[:notice] = 'The book was created successfully.' if @book.save
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

  private

  def book_params
    params.require(:book).permit(:title, :short_description, :long_description, :cover_image_file)
  end

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_book
    @book = Book.find(params[:id])
  end
end
