SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    if administrator_signed_in?
      primary.item :subscribers, 'Subscribers', admin_subscribers_path
      primary.item :inquiries, inquiry_nav_item_caption, admin_inquiries_path
      primary.item :users, 'Users', admin_users_path
      primary.item :approvals, 'Approvals', '#' do |approvals|
        approvals.item :bios, bio_nav_item_caption, admin_bios_path
        approvals.item :books, book_nav_item_caption, admin_book_versions_path do |books|
          books.auto_highlight = false
          books.dom_class = 'nav nav-tabs'
          books.item :pending, 'Pending', admin_book_versions_path, highlights_on: -> { book_path?('pending') }
          books.item :approved, 'Approved', admin_book_versions_path(status: :approved), highlights_on: -> { book_path?('approved') }
          books.item :rejected, 'Rejected', admin_book_versions_path(status: :rejected), highlights_on: -> { book_path?('rejected') }
        end
      end
      primary.item :campaigns, 'Campaigns', admin_campaigns_path, highlights_on: ->{false} do |campaigns|
        campaigns.auto_highlight = false
        campaigns.dom_class = 'nav nav-tabs'
        campaigns.item :active, 'Current', admin_campaigns_path, highlights_on: ->{ campaign_path?('current') }
        campaigns.item :inactive, 'Past', admin_campaigns_path(status: :past), highlights_on: ->{ campaign_path?('past') }
      end
      primary.item :payments, 'Payments', admin_payments_path, highlights_on: ->{ payment_path?('pending') } do |payments|
        payments.auto_highlight = false
        payments.dom_class = 'nav nav-tabs'
        payments.item :pending, 'Pending', admin_payments_path, highlights_on: ->{ payment_path?('pending') }
        payments.item :approved, 'Approved', admin_payments_path(status: :approved), highlights_on: ->{ payment_path?('approved') }
        payments.item :completed, 'Completed', admin_payments_path(status: :completed), highlights_on: ->{ payment_path?('completed') }
        payments.item :failed, 'Failed', admin_payments_path(status: :failed), highlights_on: ->{ payment_path?('failed') }
        payments.item :refunded, 'Refunded', admin_payments_path(status: :refunded), highlights_on: ->{ payment_path?('refunded') }
      end
      primary.item :rewards, 'Rewards', '#' do |rewards_item|
        rewards_item.item :manage_rewards, 'Manage Rewards', admin_house_rewards_path
        rewards_item.item :reward_fulfillment, 'Reward fulfillment', admin_fulfillments_path
      end
      primary.item :sign_out, 'Sign out', destroy_administrator_session_path, method: :delete
    end
  end
end
