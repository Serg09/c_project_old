class AuthorsController < ApplicationController
  before_filter :authenticate_author!
  before_filter :load_author

  respond_to :html

  def show

    puts "show"
    puts current_author

    authorize! :show, @author
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
    @author ||= current_author
  end
end
