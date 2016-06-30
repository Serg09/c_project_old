module ContributionsHelper
  def expiration_month_options
    [
      ['01-January', 1],
      ['02-February', 2],
      ['03-March', 3],
      ['04-April', 4],
      ['05-May', 5],
      ['06-June', 6],
      ['07-July', 7],
      ['08-August', 8],
      ['09-September', 9],
      ['10-October', 10],
      ['11-November', 11],
      ['12-December', 12],
    ]
  end

  def expiration_year_options
    years = Date.today.year..Float::INFINITY
    years.take(8)
  end
end
