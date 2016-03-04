SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    primary.item :authors, author_nav_item_caption, admin_authors_path, if: ->{administrator_signed_in?} do |authors|
      authors.auto_highlight = false
      authors.dom_class = 'nav nav-tabs'
      authors.item :pending, 'Pending', admin_authors_path, highlights_on: -> { author_path?(Author.PENDING) }
      authors.item :approved, 'approved', admin_authors_path(status: :approved), highlights_on: -> { author_path?(Author.APPROVED) }
      authors.item :rejected, 'Rejected', admin_authors_path(status: :rejected), highlights_on: -> { author_path?(Author.REJECTED) }
    end
    primary.item :bios, bio_nav_item_caption, admin_bios_path, if: ->{administrator_signed_in?} do |bios|
      bios.auto_highlight = false
      bios.dom_class = 'nav nav-tabs'
      bios.item :pending, 'Pending', admin_bios_path, highlights_on: -> { bio_path?(Bio.PENDING) }
      bios.item :approved, 'Approved', admin_bios_path(status: :approved), highlights_on: -> { bio_path?(Bio.APPROVED) }
      bios.item :rejected, 'Rejected', admin_bios_path(status: :rejected), highlights_on: -> { bio_path?(Bio.REJECTED) }
    end
    primary.item :books, book_nav_item_caption, admin_book_versions_path, if: ->{administrator_signed_in?} do |books|
      books.auto_highlight = false
      books.dom_class = 'nav nav-tabs'
      books.item :pending, 'Pending', admin_book_versions_path, highlights_on: -> { book_path?(BookVersion.PENDING) }
      books.item :approved, 'Approved', admin_book_versions_path(status: :approved), highlights_on: -> { book_path?(BookVersion.APPROVED) }
      books.item :rejected, 'Rejected', admin_book_versions_path(status: :rejected), highlights_on: -> { book_path?(BookVersion.REJECTED) }
    end
    primary.item :inquiries, inquiry_nav_item_caption, admin_inquiries_path, if: ->{administrator_signed_in?} do |inquiries|
      inquiries.auto_highlight = false
      inquiries.dom_class = 'nav nav-tabs'
      inquiries.item :active, 'Active', admin_inquiries_path, highlights_on: -> { inquiry_path?(false) }
      inquiries.item :archived, 'Archived', admin_inquiries_path(archived: true), highlights_on: -> { inquiry_path?(true) }
    end
    primary.item :administrators, 'Administrators', '/', if: ->{administrator_signed_in?}
    primary.item :sign_out, 'Sign out', destroy_administrator_session_path, if: -> { administrator_signed_in? }, method: :delete
  end
end
