class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:show, :edit, :update]
  before_filter :load_user, only: [:show, :edit, :update]

  respond_to :html

  def index
    if user_signed_in?
      redirect_to user_path(current_user)
    else
      #TODO Do we need to be able to list users for unauthenticated users?
      flash[:warn] = "We were unable to find the information you were looking for. Please check the URL and try again."
      redirect_to root_path
    end
  end

  def show
    authorize! :show, @user
    respond_with @user
  end

  def unsubscribe
    @user = User.find_by(unsubscribe_token: params[:token])
    if @user && @user.update_attribute(:unsubscribed, true)
      flash.now[:notice] = 'You have been unsubscribed successfully.'
    else
      flash[:alert] = 'We were unable to unsubscribe your account. Please sign in an edit your email preferences directly'
      redirect_to new_user_session_path
    end
  end

  def edit
    authorize! :update, @user
  end

  def update
    authorize! :update, @user
    @user.update_attributes user_params
    flash[:notice] = "Your profile was updated successfully." if @user.save
    respond_with @user
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :contactable)
  end

  def load_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end
