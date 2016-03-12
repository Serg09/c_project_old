module BooksHelper
  def book_index_class(book)
    return 'warning' if book.pending_version
    return 'danger' if book.rejected?
    return ''
  end

  def can_campaign?(book)
    book.approved_version.present? && book.author.active_bio.present?
  end

  def cover_image_path(book_version)
    if book_version.cover_image_id
      image_path book_version.cover_image_id, width: 215, height: 344
    else
      asset_path 'cover_image_not_available.png'
    end
  end

  def edit_book_link(book)
    path = if book.pending_version
             edit_book_version_path(book.pending_version)
           else
             new_book_book_version_path(book)
           end
    link_to path, class: 'btn btn-info btn-xs edit-button', title: 'Click here to edit this book.'  do
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
