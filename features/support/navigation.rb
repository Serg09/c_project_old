module Navigation
  def description_to_id(description)
    description.gsub(/\s+/, '-').downcase
  end

  def path_for(identifier)
    case identifier
    when "the welcome page" then root_path
    when "the administrator sign in page" then new_administrator_session_path
    when "the administration home page" then admin_root_path
    when "the administrator home page" then admin_root_path
    when "the author home page" then author_root_path
    else raise "Unrecognized path identifier \"#{identifier}\""
    end
  end

  def locator_for(identifier)
    case identifier
    when "the main menu" then "#main-menu"
    when "the main content" then "#main_content"
    when "the admin content" then "#admin-content"
    when "the page title" then "#page-title"
    when "the book title" then "#book-title"
    when "the notification area" then "#notifications"
    when "the genre list" then '.genre-list'
    when /the (.*) table/ then  "##{description_to_id($1)}-table"
    when /the (\d(?:st|nd|rd|th)) (.+) row/ then "##{hyphenize($2).pluralize}-table tr:nth-child(#{$1.to_i + 1})"
    else raise "Unrecognized locator identifier \"#{identifier}\""
    end
  end

  def hyphenize(words)
    words.gsub(/\s/, "-")
  end
end
World(Navigation)
