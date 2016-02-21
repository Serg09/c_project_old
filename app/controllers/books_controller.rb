class BooksController < ApplicationController
  before_filter :load_book, only: [:show, :edit, :update, :approve, :reject]
  before_filter :load_author, only: [:new, :create]
  respond_to :html

  def index
    @author = Author.find(params[:author_id]) if params[:author_id].present?
    @books = @author.try(:books) || Book.all
  end

  def show
    authorize! :show, @book
  end

  def new
    @book = new_book
    authorize! :create, @book
  end

  def create
    @book = new_book(book_params)
    authorize! :create, @book
    genres_from_params.each{|genre| @book.versions[0].genres << genre}
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

  private

  def new_book(params = {})
    book = @author.books.new
    book.versions.new(params.merge(book: book))
    book
  end

  def book_params
    params.require(:book).permit(:title, :short_description, :long_description, :cover_image_file, :sample_file)
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
