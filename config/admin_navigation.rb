SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    primary.item :authors, author_nav_item_caption, authors_path do |authors|
      authors.auto_highlight = false
      authors.dom_class = 'nav nav-tabs'
      authors.item :pending, 'Pending', authors_path, highlights_on: -> { author_path?(Author.PENDING) }
      authors.item :accepted, 'Accepted', authors_path(status: :accepted), highlights_on: -> { author_path?(Author.ACCEPTED) }
      authors.item :rejected, 'Rejected', authors_path(status: :rejected), highlights_on: -> { author_path?(Author.REJECTED) }
    end
    primary.item :bios, bio_nav_item_caption, bios_path do |bios|
      bios.auto_highlight = false
      bios.dom_class = 'nav nav-tabs'
      bios.item :pending, 'Pending', bios_path, highlights_on: -> { bio_path?(Bio.PENDING) }
      bios.item :approved, 'Approved', bios_path(status: :approved), highlights_on: -> { bio_path?(Bio.APPROVED) }
      bios.item :rejected, 'Rejected', bios_path(status: :rejected), highlights_on: -> { bio_path?(Bio.REJECTED) }
    end
    primary.item :inquiries, inquiry_nav_item_caption, inquiries_path do |inquiries|
      inquiries.auto_highlight = false
      inquiries.dom_class = 'nav nav-tabs'
      inquiries.item :active, 'Active', inquiries_path, highlights_on: -> { inquiry_path?(false) }
      inquiries.item :archived, 'Archived', inquiries_path(archived: true), highlights_on: -> { inquiry_path?(true) }
    end
    primary.item :administrators, 'Administrators', '/'
    primary.item :sign_out, 'Sign out', destroy_administrator_session_path, if: -> { administrator_signed_in? }, method: :delete
  end
end
