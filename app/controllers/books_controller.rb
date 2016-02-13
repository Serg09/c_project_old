class BooksController < ApplicationController
  respond_to :html

  def index
  end

  def show
  end

  def new
  end

  def create
    @book = Author.books.new(book_params)
    flash[:notice] = 'The book was created successfully.' if @book.save
    respond_with @book
  end

  def edit
  end

  def update
  end
end
