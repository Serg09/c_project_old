module PagesHelper
  def figure_tag(image_path, alt_text, &block)
    content_tag 'figure', class: 'book-caption-trigger' do
      result = image_tag image_path, alt: alt_text
      result += content_tag 'figcaption', { class: 'book-caption'}, &block
    end
  end
end
