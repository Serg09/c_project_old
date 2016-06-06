SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active' #TODO make this the default in the renderer

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav' # TODO set a reasonable default in the renderer

    primary.item :about, 'About', pages_about_us_path do |about|
      about.item :package_pricing, 'Package Pricing', pages_package_pricing_path
      about.item :a_la_carte, 'A La Carte Pricing', pages_a_la_carte_pricing_path
      about.item :faqs, 'FAQs', pages_faqs_path
      about.item :about_us, 'About Us', pages_about_us_path
      about.item :contact_us, 'Contact us', new_inquiry_path
      about.item :book_incubator, 'Book Incubator', pages_book_incubator_path
    end
    primary.item :authors, 'Authors', '#'
    primary.item :books, 'Books', browse_books_path
    if !AppSetting.sign_in_disabled?
      if user_signed_in?
        primary.item :profile, 'Profile' do |profile_item|
          profile_item.item :view_profile, 'View', user_path(current_user)
          profile_item.item :bio, 'Bio', bios_path
          profile_item.item :my_books, 'My books', books_path
          profile_item.item :reward_fulfillment, 'Reward fulfillment', fulfillments_path
          profile_item.item :author_sign_out, 'Sign Out', destroy_user_session_path, method: :delete, if: ->{user_signed_in? && !AppSetting.sign_in_disabled?}
        end
      else
        primary.item :author_sign_in, 'Log in', new_user_session_path
        primary.item :author_sign_up, 'Signup', new_user_registration_path, if: ->{!user_signed_in? && !AppSetting.sign_in_disabled?}
      end
    end
  end
end
