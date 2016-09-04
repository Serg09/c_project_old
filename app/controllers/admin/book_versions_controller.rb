class Admin::BookVersionsController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_book_version, only: [:show, :update, :approve, :reject]
  respond_to :html
  layout 'admin'

  def index
    @book_versions = book_versions_by_status.paginate(page: params[:page])
  end

  def show
    authorize! :show, @book_version
  end

  def update
    @book_version.update_attributes book_version_params.except(:genres)
    update_genres
    flash[:notice] = 'The book was updated successfully.' if @book_version.save
    respond_with @book_version, location: admin_author_books_path(@book_version.book.author_id)
  end

  def approve
    authorize! :approve, @book_version
    if @book_version.approve!
      BookMailer.approval(@book_version).deliver_now unless @book_version.author.unsubscribed?
      redirect_to admin_book_versions_path, notice: 'The book has been approved successfully.'
    else
      render :show
    end
  end

  def reject
    authorize! :reject, @book_version
    if @book_version.reject!
      BookMailer.rejection(@book_version).deliver_now unless @book_version.author.unsubscribed?
      redirect_to admin_book_versions_path, notice: 'The book has been rejected successfully.'
    else
      render :show
    end
  end

  private

  def book_versions_by_status
    BookVersion.where(status: params[:status] || :pending)
  end

  def load_book_version
    @book_version = BookVersion.find(params[:id])
  end

  def book_version_params
    params.require(:book_version).permit(:title,
                                         :short_description,
                                         :long_description,
                                         :cover_image_file,
                                         :sample_file,
                                         genres: [])
  end

  def set_diff(current, target)
    to_add = target - current
    to_remove = current - target
    [to_add, to_remove]
  end

  def genres_from_params
    genre_ids = params[:book_version][:genres]
    if genre_ids
      Genre.find(genre_ids)
    else
      []
    end
  end

  def update_genres
    to_add, to_remove = set_diff(@book_version.genres,
                                 genres_from_params)
    to_add.each{|g| @book_version.genres << g}
    to_remove.each{|g| @book_version.genres.delete g}
  end
end
