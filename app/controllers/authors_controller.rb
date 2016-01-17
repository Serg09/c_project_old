class AuthorsController < ApplicationController
  before_filter :authenticate_author!, only: [:show, :edit, :update]
  before_filter :authenticate_administrator!, only: [:index]
  before_filter :load_author, only: [:show, :edit, :update]
  authorize_resource

  respond_to :html

  def index
  end

  def show
  end

  def edit
  end

  def update
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
