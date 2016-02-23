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
                      @book.pending_version ||
                        @book.approved_version ||
                        @book.versions.rejected.first
                    else
                      @book.approved_version
                    end
    authorize! :show, @book_version
  end

  def new
    @book = Book.new_book(@author)
    @book_version = @book.pending_version
    authorize! :create, @book
  end

  def create
    @book = Book.new_book(@author, book_params)
    @book_version = @book.pending_version
    authorize! :create, @book
    genres_from_params.each{|genre| @book.pending_version.genres << genre}
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
    if @book.pending_version
      @book.pending_version.update_attributes book_params
      # remove existing genres not posted
      @book.pending_version.genres.reject{|existing| !genres_from_params.any?{|specified| specified.id == existing.id}}
      # add posted genres not present
      genres_from_params.each do |specified|
        @book.pending_version.genres << specified unless @book.pending_versions.any?{|g| g.id == specified.id}
      end
    else
      @book.new_version! book_params
      genres_from_params.each{|genre| @book.pending_version.genres << genre}
    end
    if @book.save
      flash[:notice] = 'The book was updated successfully.'
      BookMailer.edit_submission(@book).deliver_now
    end
    respond_with @book
  end

  private

  def book_params
    params.require(:book).permit(:title, :short_description, :long_description, :cover_image_file, :sample_file)
  end

  def genres_from_params
    @genres_from_paramms ||= if params[:genres]
                               params[:genres].map{|id| Genre.find(id)}
                             else
                               []
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
end
