class Admin::AuthorsController < ApplicationController
  before_filter :safe_authenticate_administrator!
  before_filter :load_author, only: [:show, :approve, :reject]
  layout 'admin'
  respond_to :html

  def index
    authorize! :read, Author
    @authors = Author.where(status: query_status)
    respond_with @authors
  end

  def show
    authorize! :show, @author
    respond_with @author
  end

  def approve
    authorize! :approve, @author
    @author.status = Author.APPROVED
    if @author.save
      flash[:notice] = 'The author has been approved successfully.'
      redirect_to admin_authors_path
    else
      flash.now[:error] = 'Unable to update the author record.'
    end
  end

  def reject
    authorize! :reject, @author
    @author.status = Author.REJECTED
    if @author.save
      flash[:notice] = 'The author has been rejected successfully.'
      redirect_to admin_authors_path
    else
      flash.now[:error] = 'Unable to update the author record.'
    end
  end

  private

  def load_author
    @author = params[:id] ? Author.find(params[:id]) : current_author
  end

  def query_status
    params[:status] || Author.PENDING
  end
end
