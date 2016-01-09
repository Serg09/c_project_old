module Navigation
  def path_for(identifier)
    case identifier
    when "the welcome page" then "/"
    end
  end

  def locator_for(identifier)
    case identifier
    when "the main menu" then "#main-menu"
    end
  end
end
World(Navigation)
