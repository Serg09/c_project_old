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
    primary.item :authors, 'Authors' do |authors|
      authors.item :bio, 'Bio', bios_path, if: ->{author_signed_in?}
      authors.item :author_sign_in, 'Log in', new_author_session_path, if: ->{!author_signed_in? && !AppSetting.sign_in_disabled?}
      authors.item :author_sign_up, 'Signup', new_author_registration_path, if: ->{!author_signed_in? && !AppSetting.sign_in_disabled?}
      authors.item :author_sign_out, 'Sign Out', destroy_author_session_path, method: :delete, if: ->{author_signed_in? && !AppSetting.sign_in_disabled?}
    end
    primary.item :books, 'Books', pages_books_path
  end
end
