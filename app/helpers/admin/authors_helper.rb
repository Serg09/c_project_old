module Admin::AuthorsHelper
  def edit_author_bio_link(author)
    link_to author_bio_path(author), class: "btn #{author_bio_button_class(author)}", title: 'Click here to edit the bio for this author' do
      content_tag :span, class: 'glyphicon glyphicon-file', 'aria-hidden' => true
    end
  end

  private

  def author_bio_path(author)
    author.bio.nil? ?
      new_admin_author_bio_path(author) :
      edit_admin_bio_path(author.bio)
  end

  def author_bio_button_class(author)
    author.bio.nil? ?
      'btn-default' :
      'btn-info'
  end
end
