SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    primary.item :users, user_nav_item_caption, admin_users_path, if: ->{administrator_signed_in?} do |users|
      users.auto_highlight = false
      users.dom_class = 'nav nav-tabs'
      users.item :pending, 'Pending', admin_users_path, highlights_on: -> { user_path?(User.PENDING) }
      users.item :approved, 'approved', admin_users_path(status: :approved), highlights_on: -> { user_path?(User.APPROVED) }
      users.item :rejected, 'Rejected', admin_users_path(status: :rejected), highlights_on: -> { user_path?(User.REJECTED) }
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
    primary.item :campaigns, 'Campaigns', admin_campaigns_path, if: ->{administrator_signed_in?}, highlights_on: ->{false} do |campaigns|
      campaigns.auto_highlight = false
      campaigns.dom_class = 'nav nav-tabs'
      campaigns.item :active, 'Current', admin_campaigns_path, highlights_on: ->{ campaign_path?('current') }
      campaigns.item :inactive, 'Past', admin_campaigns_path(status: :past), highlights_on: ->{ campaign_path?('past') }
    end
    primary.item :inquiries, inquiry_nav_item_caption, admin_inquiries_path, if: ->{administrator_signed_in?} do |inquiries|
      inquiries.auto_highlight = false
      inquiries.dom_class = 'nav nav-tabs'
      inquiries.item :active, 'Active', admin_inquiries_path, highlights_on: -> { inquiry_path?(false) }
      inquiries.item :archived, 'Archived', admin_inquiries_path(archived: true), highlights_on: -> { inquiry_path?(true) }
    end
    primary.item :rewards, 'Rewards', admin_house_rewards_path
    primary.item :reward_fulfillment, 'Reward fulfillment', admin_fulfillments_path
    primary.item :administrators, 'Administrators', '/', if: ->{administrator_signed_in?}
    primary.item :sign_out, 'Sign out', destroy_administrator_session_path, if: -> { administrator_signed_in? }, method: :delete
  end
end
