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
    create_next_step

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

  def create_next_step
    case
    when !@user.active_bio
      @next_step = OpenStruct.new(
        title: 'Create Your Bio!',
        content: <<-eos
          First, you'll need to create a bio. It can be simple for now, but
          before adding any book titles or activating a campaign, do this
          first. <a href="#{new_bio_path}">Click here</a> to get started.
        eos
      )
    when @user.books.none?
      @next_step = OpenStruct.new(
        title: 'Create Your First Book!',
        content: <<-eos
          Now you're ready to start on your first book. Tell readers about
          a book you've already written, or one that you're been thinking
          about writing. They'll even be able to help you fund it.
          <a href="#{new_book_path}">Click here</a> to get started.
        eos
      )
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :contactable, :subscribed)
  end

  def load_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end
