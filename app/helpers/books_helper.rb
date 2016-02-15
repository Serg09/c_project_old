module BooksHelper
  def genre_groups(group_count)
    result = Hash.new{|h, k| h[k] = []}
    Genre.alphabetized.each_with_index do |genre, index|
      group_key = index % group_count
      result[group_key] << genre
    end
    result.values
  end
end
