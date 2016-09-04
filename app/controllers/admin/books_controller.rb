class Admin::BooksController < ApplicationController
  respond_to :html
  layout 'admin'

  before_action :authenticate_administrator!
  before_action :load_author, only: [:index, :new, :create]
  before_action :load_book, only: [:edit, :update, :destroy]

  def index
    @books = @author.books.paginate(page: params[:page])
  end

  def new
    @book_creator = BookCreator.new @author
  end

  def create
    @book_creator = BookCreator.new @author, book_params
    flash[:notice] = 'The book was created successfully.' if @book_creator.create
    respond_with @book_creator.book, location: admin_author_books_path(@author)
  end

  def edit
  end

  def update
    @book.approved_version.update_attributes book_params.except(:genres)
    update_genres
    flash[:notice] = 'The book was updated successfully.' if @book.approved_version.save
    respond_with @book.approved_version, location: admin_author_books_path(@author)
  end

  def destroy
    flash[:notice] = 'The book was removed successfully.' if @book.destroy
    respond_with @book, location: admin_author_books_path(@author)
  end

  private

  def book_params
    params.require(:book).permit(:title,
                                 :short_description,
                                 :long_description,
                                 :cover_image_file,
                                 :sample_file,
                                 genres: [])
  end

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_book
    @book = Book.find(params[:id])
    @author = @book.author
  end

  def set_diff(current, target)
    to_add = target - current
    to_remove = current - target
    [to_add, to_remove]
  end

  def genres_from_params
    genre_ids = params[:book][:genres]
    if genre_ids
      Genre.find(genre_ids)
    else
      []
    end
  end

  def update_genres
    to_add, to_remove = set_diff(@book.approved_version.genres,
                                 genres_from_params)
    to_add.each{|g| @book.approved_version.genres << g}
    to_remove.each{|g| @book.approved_version.genres.delete g}
  end
end
