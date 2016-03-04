class Admin::BookVersionsController < ApplicationController
  before_filter :safe_authenticate_administrator!
  before_filter :load_book_version, only: [:show, :approve, :reject]
  respond_to :html
  layout 'admin'

  def index
    @book_versions = book_versions_by_status.paginate(page: params[:page])
  end

  def show
    authorize! :show, @book_version
  end

  def approve
    authorize! :approve, @book_version
    if @book_version.approve!
      BookMailer.approval(@book_version).deliver_now
      redirect_to admin_book_versions_path, notice: 'The book has been approved successfully.'
    else
      render :show
    end
  end

  def reject
    authorize! :reject, @book_version
    if @book_version.reject!
      BookMailer.rejection(@book_version).deliver_now
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
end
