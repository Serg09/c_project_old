class BookVersionsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_book_version, only: [:show, :edit, :update]
  before_filter :load_book, only: [:index, :new, :create]
  respond_to :html

  def index
    authorize! :version, @book
  end

  def show
    authorize! :show, @book_version
  end

  def new
    if @book.pending_version
      redirect_to edit_book_version_path(@book.pending_version)
      return
    end
    @book_version = @book.working_version.new_copy
    authorize! :create, @book_version
  end

  def create
    if @book.pending_version
      redirect_to edit_book_version_path(@book.pending_version)
      return
    end

    @book_version = @book.versions.new(book_version_params)
    authorize! :create, @book_version
    genres_from_params.each{|g| @book_version.genres << g}
    if @book_version.save
      flash[:notice] = 'The book was updated successfully.'
      BookMailer.edit_submission(@book_version).deliver_now
    end
    respond_with @book_version
  end

  def edit
    with_permission do
      unless @book_version.pending?
        redirect_to new_book_book_version_path(@book_version.book_id)
        return
      end
    end
  end

  def update
    with_permission do
      authorize! :update, @book_version
      @book_version.update_attributes book_version_params
      update_genres
      flash[:notice] = "The book was updated successfully." if @book_version.save
      respond_with @book_version, location: book_path(@book_version.book)
    end
  end

  private

  def book_author_id
    @book.try(:author_id) || @book_version.book.author_id
  end

  def book_version_params
    params.require(:book_version).permit(:title,
                                         :short_description,
                                         :long_description,
                                         :cover_image_file,
                                         :cover_image_id,
                                         :sample_file,
                                         :sample_id)
  end

  def genres_from_params
    genre_ids = params.require(:book_version).permit(genres: [])[:genres]
    if genre_ids
      Genre.find(genre_ids)
    else
      []
    end
  end

  def load_book
    @book = Book.find(params[:book_id])
  end

  def load_book_version
    @book_version = BookVersion.find(params[:id])
  end

  def set_diff(current, target)
    to_add = target - current
    to_remove = current - target
    [to_add, to_remove]
  end

  def update_genres
    to_add, to_remove = set_diff(@book_version.genres,
                                 genres_from_params)
    to_add.each{|g| @book_version.genres << g}
    to_remove.each{|g| @book_version.genres.delete g}
  end

  def with_permission
    unless user_signed_in?
      # Not a user, they can't edit it
      redirect_to root_path, notice: "We were not able to find the resource you requested."
      return
    end

    unless current_user.id == @book_version.book.author_id
      # Not the owner, they can't edit it
      redirect_to user_root_path, notice: "We were not able to find the resource you requested."
      return
    end

    unless @book_version.pending?
      # they can't edit it, but they can create a new version
      redirect_to new_book_book_version_path(@book_version.book)
      return
    end

    yield if block_given?
  end
end
