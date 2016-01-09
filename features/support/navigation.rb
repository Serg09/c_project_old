module Navigation
  def path_for(identifier)
    case identifier
    when "the welcome page" then "/"
    else raise "Unrecognized path identifier \"#{identifier}\""
    end
  end

  def locator_for(identifier)
    case identifier
    when "the main menu" then "#main-menu"
    when "the page title" then ".title-bar"
    else raise "Unrecognized locator identifier \"#{identifier}\""
    end
  end
end
World(Navigation)
