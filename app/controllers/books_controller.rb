class BooksController < ApplicationController
  before_filter :load_book, only: [:show, :edit, :update, :approve, :reject]
  before_filter :load_author, only: [:new, :create]
  respond_to :html

  def index
    @author = Author.find(params[:author_id]) if params[:author_id].present?
    @books = @author.try(:books) || Book.all
  end

  def show
    @book_version = if author_signed_in? && current_author.id == @author.id
                      @book.working_version
                    else
                      @book.approved_version
                    end
    if @book_version
      redirect_to book_version_path(@book_version)
    else
      redirect_to not_found_redirect_path, notice: "We were unable to find the resource you requested."
    end
  end

  def new
    @book_creator = BookCreator.new @author
    authorize! :create, @book_creator.book
  end

  def create
    @book_creator = BookCreator.new @author, book_params
    authorize! :create, @book_creator.book
    if @book_creator.create
      flash[:notice] = 'Your book has been submitted successfully.'
      BookMailer.submission(@book_creator.book_version).deliver_now
    end
    respond_with @book_creator.book
  end

  def edit
    authorize! :update, @book
    redirect_to edit_book_redirect_path
  end

  def update
    unless author_signed_in?
      redirect_to root_path, notice: "We were not able to find the resource you requested."
      return
    end

    unless current_author.id == @book.author_id
      redirect_to author_root_path, notice: "We were not able to find the resource you requested."
      return
    end

    if @book.pending_version
      redirect_to edit_book_version_path(@book.pending_version)
    else
      redirect_to new_book_book_version_path(@book)
    end
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

  def edit_book_redirect_path
    if @book.pending_version
      edit_book_version_path @book.pending_version
    else
      new_book_book_version_path @book
    end
  end

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_book
    @book = Book.find(params[:id])
    @book_version = @book.pending_version || @book.approved_version || @book.rejected_version
    @author = @book.author
  end

  def not_found_redirect_path
    if author_signed_in?
      author_root_path
    else
      root_path
    end
  end
end
