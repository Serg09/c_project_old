class BookCreator
  attr_reader :book, :book_version

  delegate :to_key,
    :persisted?,
    :author,
    to: :book
  delegate :title,
    :short_description,
    :long_description,
    :genres,
    to: :book_version

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

  def model_name
    ActiveModel::Name.new(Book)
  end

  def to_model
    self
  end
end
