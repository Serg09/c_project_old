module BooksHelper
  def book_index_class(book)
    return 'warning' if book.pending_version
    return 'danger' if book.rejected?
    return ''
  end

  def edit_book_link(book)
    path = if book.pending_version
             edit_book_version_path(book.pending_version)
           else
             new_book_book_version_path(book)
           end
    link_to path, class: 'btn btn-default btn-xs edit-button', title: 'Click here to edit this book.'  do
      content_tag :span, '', :class => 'glyphicon glyphicon-pencil', 'aria-hidden' => true
    end
  end

  def genre_groups(group_count)
    result = Hash.new{|h, k| h[k] = []}
    Genre.alphabetized.each_with_index do |genre, index|
      group_key = index % group_count
      result[group_key] << genre
    end
    result.values
  end
end
