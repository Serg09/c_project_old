class AuthorsController < ApplicationController
  before_filter :authenticate_user!, only: [:show, :edit, :update]
  before_filter :load_author, only: [:show, :edit, :update]

  respond_to :html

  def index
    if author_signed_in?
      redirect_to author_path(current_author)
    else
      #TODO Do we need to be able to list authors for unauthenticated users?
      flash[:warn] = "We were unable to find the information you were looking for. Please check the URL and try again."
      redirect_to root_path
    end
  end

  def show
    authorize! :show, @author
    respond_with @author
  end

  def edit
    authorize! :update, @author
  end

  def update
    authorize! :update, @author
    @author.update_attributes author_params
    flash[:notice] = "Your profile was updated successfully." if @author.save
    respond_with @author
  end

  private

  def author_params
    params.require(:author).permit(:first_name, :last_name, :phone_number, :contactable)
  end

  def load_author
    @author = params[:id] ? Author.find(params[:id]) : current_author
  end
end
