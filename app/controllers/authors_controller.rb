class AuthorsController < ApplicationController
  before_filter :authenticate_author!
  load_and_authorize_resource

  respond_to :html

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
end
