class Admin::UsersController < ApplicationController
  before_filter :authenticate_administrator!
  before_filter :load_user, only: [:show]
  layout 'admin'
  respond_to :html

  def index
    authorize! :read, User
    @users = User.order(:last_name, :first_name).paginate(page: params[:page])
    respond_with @users
  end

  def show
    authorize! :show, @user
    respond_with @user
  end

  private

  def load_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end
