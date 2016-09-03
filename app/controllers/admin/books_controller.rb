class Admin::BooksController < ApplicationController
  respond_to :html

  before_action :load_author, only: [:index, :new, :create]

  def index
  end

  def new
  end

  def create
    @book_creator = BookCreator.new @author, book_params
    flash[:notice] = 'The book was created successfully.' if @book_creator.create
    respond_with @book_creator.book
  end

  def edit
  end

  def update
  end

  def destroy
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
end
