module Navigation
  def description_to_id(description)
    description.gsub(/\s+/, '-').downcase
  end

  def path_for(identifier)
    case identifier
    when "the welcome page" then root_path
    when "the administrator sign in page" then new_administrator_session_path
    when "the administration home page" then admin_root_path
    when "the author home page" then author_root_path
    else raise "Unrecognized path identifier \"#{identifier}\""
    end
  end

  def locator_for(identifier)
    case identifier
    when "the main menu" then "#main-menu"
    when "the main content" then "#main_content"
    when "the page title" then "#page-title"
    when "the notification area" then "#notifications"
    when /the (.*) table/ then  "##{description_to_id($1)}-table"
    else raise "Unrecognized locator identifier \"#{identifier}\""
    end
  end
end
World(Navigation)
