class BookVersionsController < ApplicationController
  before_filter :authenticate_author!, except: [:show]
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
    @book_version = @book.approved_version.new_copy
    authorize! :create, @book_version
  end

  def create
    if @book.pending_version
      redirect_to edit_book_version_path(@book.pending_version)
      return
    end

    @book_version = @book.versions.new(book_version_params)
    authorize! :create, @book_version
    genres_from_params.each do |genre|
      @book_version.genres << genre unless @book_version.genres.any?{|g| g.id = genre.id}
    end
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
      genres_from_params.each{|g| @book_version.genres << g}
      @book_version.update_attributes book_version_params
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
      genre_ids.map{|id| Genre.find(id)}
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

  def with_permission
    unless author_signed_in?
      # Not an author, they can't edit it
      redirect_to root_path, notice: "We were not able to find the resource you requested."
      return
    end

    unless current_author.id == @book_version.book.author_id
      # Not the owner, they can't edit it
      redirect_to author_root_path, notice: "We were not able to find the resource you requested."
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
