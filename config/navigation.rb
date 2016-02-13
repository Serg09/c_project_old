SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active' #TODO make this the default in the renderer

  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav' # TODO set a reasonable default in the renderer

    primary.item :about, 'About', pages_about_us_path do |about|
      about.item :package_pricing, 'Package Pricing', pages_package_pricing_path
    end
  end
end
