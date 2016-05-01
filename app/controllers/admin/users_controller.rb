class Admin::UsersController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_user, only: [:show, :approve, :reject]
  layout 'admin'
  respond_to :html

  def index
    authorize! :read, User
    @users = User.where(status: query_status).paginate(page: params[:page])
    respond_with @users
  end

  def show
    authorize! :show, @user
    respond_with @user
  end

  def approve
    authorize! :approve, @user
    @user.status = User.APPROVED
    if @user.save
      flash[:notice] = 'The user has been approved successfully.'
      redirect_to admin_users_path
    else
      flash.now[:error] = 'Unable to update the user record.'
    end
  end

  def reject
    authorize! :reject, @user
    @user.status = User.REJECTED
    if @user.save
      flash[:notice] = 'The user has been rejected successfully.'
      redirect_to admin_users_path
    else
      flash.now[:error] = 'Unable to update the user record.'
    end
  end

  private

  def load_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end

  def query_status
    params[:status] || User.PENDING
  end
end
