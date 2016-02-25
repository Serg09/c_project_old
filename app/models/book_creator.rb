class BookCreator
  attr_reader :book, :book_version

  def initialize(author, attributes = {})
    genres = (attributes || {}).delete(:genres) || []
    @book = author.books.new
    @book_version = @book.versions.new(attributes.merge(book: @book))
    genres.map{|id| Genre.find(id)}.each do |genre|
      @book_version.genres << genre
    end
  end

  def create
    @book.save
  end

  def errors
    @book_version.errors # Ideally we'd return the book errors too, but as of now there's not much there
  end

  def valid?
    @book.valid? && @book_version.valid?
  end
end
