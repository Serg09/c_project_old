module AuthorsHelper
  def package_options_for_select
    options_for_select [
      ['Starter (Free)', 1],
      ['Basic', 2],
      ['Print', 3],
      ['Print Premium', 4],
      ['CS Pro', 5],
    ]
  end
end
