SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    primary.item :authors, author_nav_item_caption, authors_path do |authors|
      authors.auto_highlight = false
      authors.dom_class = 'nav nav-tabs'
      authors.item :pending, 'Pending', authors_path, highlights_on: -> { (params[:status] || 'pending') == 'pending' }
      authors.item :accepted, 'Accepted', authors_path(status: :accepted), highlights_on: -> { params[:status] == 'accepted' }
      authors.item :rejected, 'Rejected', authors_path(status: :rejected), highlights_on: -> { params[:status] == 'rejected' }
    end
    primary.item :inquiries, 'Inquiries', inquiries_path
    primary.item :administrators, 'Administrators', '/'
    primary.item :sign_out, 'Sign out', destroy_administrator_session_path, if: -> { administrator_signed_in? }, method: :delete
  end
end
