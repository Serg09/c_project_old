class Admin::AuthorsController < ApplicationController
  respond_to :html
  before_action :authenticate_administrator!
  before_action :load_author, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
  end

  def create
    @author = Author.new author_params
    flash[:notice] = 'The author was created successfully.' if @author.save
    respond_with @author, location: admin_authors_path
  end

  def show
  end

  def edit
  end

  def update
    @author.update_attributes author_params
    flash[:notice] = 'The author was updated successfully.' if @author.save
    respond_with @author, location: admin_authors_path
  end

  def destroy
    flash[:notice] = 'The author was removed successfully.' if @author.destroy
    respond_with @author, location: admin_authors_path
  end

  private

  def author_params
    params.require(:author).permit(:first_name, :last_name)
  end

  def load_author
    @author = Author.find(params[:id])
  end
end
