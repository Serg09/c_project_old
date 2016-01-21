class AuthorsController < ApplicationController
  before_filter :authenticate_user!, only: [:show, :edit, :update, :accept, :reject]
  before_filter :load_author, only: [:show, :edit, :update, :accept, :reject]

  respond_to :html

  def index
    authorize! :read, Author
    @authors = Author.all
    respond_with @authors do |format|
      format.html { render layout: 'admin' }
    end
  end

  def show
    authorize! :show, @author
    respond_with @author do |format|
      format.html { render layout: administrator_signed_in? ? 'admin' : 'application' }
    end
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

  def accept
    authorize! :accept, @author
    @author.status = Author.ACCEPTED
    flash[:notice] = 'The author has been accepted successfully.' if @author.save
    redirect_to authors_path
  end

  def reject
    authorize! :reject, @author
    @author.status = Author.REJECTED
    flash[:notice] = 'The author has been rejected successfully.' if @author.save
    redirect_to authors_path
  end

  private

  def authenticate_user!
    return if administrator_signed_in?
    authenticate_author!
  end

  def author_params
    params.require(:author).permit(:first_name, :last_name, :phone_number, :contactable)
  end

  def load_author
    @author = params[:id] ? Author.find(params[:id]) : current_author
  end
end
