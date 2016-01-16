class AuthorsController < ApplicationController
  before_filter :lookup_author

  def show
  end

  def edit
  end

  def update
  end

  private

  def lookup_author
    @author = Author.find(params[:id])
  end
end
