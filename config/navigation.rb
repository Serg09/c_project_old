SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active' #TODO make this the default in the renderer

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav navbar-right' # TODO set a reasonable default in the renderer

    primary.item :about, 'About', pages_about_us_path do |about|
      about.item :about_us, 'About Us', pages_about_us_path
      about.item :what_we_do, 'What We Do', pages_what_we_do_path
      about.item :why_we_do_it, 'Why We Do It', pages_why_path
      about.item :contact_us, 'Contact us', new_inquiry_path
      about.item :our_team, 'Our team', pages_our_team_path
    end
    primary.item :services, 'Services' do |services_item|
      services_item.item :a_la_carte, 'A La Carte Pricing', pages_a_la_carte_pricing_path
      services_item.item :faqs, 'FAQs', pages_faqs_path
    end
    if AppSetting.sign_in_disabled?
      primary.item :subscribe, 'Sign up', new_subscriber_path
    else
      primary.item :readers, 'Readers' do |readers_item|
        readers_item.item :browse_authors, 'Browse authors', browse_authors_path
        readers_item.item :browse_books, 'Browse books', browse_books_path
      end
      primary.item :authors, 'Authors' do |authors_item|
        authors_item.item :author_portal, 'Author Portal', pages_author_portal_path
        if user_signed_in?
          authors_item.item :view_profile, 'Profile', user_path(current_user)
          authors_item.item :my_bio, 'My bio', bios_path
          authors_item.item :my_books, 'My books', books_path
          authors_item.item :reward_fulfillment, 'Reward fulfillment', fulfillments_path
        end
      end
      if user_signed_in?
        primary.item :author_sign_out, 'Sign Out', destroy_user_session_path, method: :delete
      else
        primary.item :author_sign_in, 'Log in', new_user_session_path
        primary.item :author_sign_up, 'Signup', new_user_registration_path
      end
    end
  end
end
