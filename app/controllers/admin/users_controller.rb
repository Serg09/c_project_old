class Admin::UsersController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_author, only: [:show, :approve, :reject]
  layout 'admin'
  respond_to :html

  def index
    authorize! :read, User
    @authors = User.where(status: query_status).paginate(page: params[:page])
    respond_with @authors
  end

  def show
    authorize! :show, @author
    respond_with @author
  end

  def approve
    authorize! :approve, @author
    @author.status = User.APPROVED
    if @author.save
      flash[:notice] = 'The author has been approved successfully.'
      redirect_to admin_users_path
    else
      flash.now[:error] = 'Unable to update the author record.'
    end
  end

  def reject
    authorize! :reject, @author
    @author.status = User.REJECTED
    if @author.save
      flash[:notice] = 'The author has been rejected successfully.'
      redirect_to admin_users_path
    else
      flash.now[:error] = 'Unable to update the author record.'
    end
  end

  private

  def load_author
    @author = params[:id] ? User.find(params[:id]) : current_author
  end

  def query_status
    params[:status] || User.PENDING
  end
end
