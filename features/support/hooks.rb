After do |scenario|
  save_and_open_page if scenario.failed? && ENV['SHOW_FAILURES']
end

After do |scenario|
  Timecop.return
end

Before do |scenario|
  Capybara.current_session.driver.header('User-Agent', 'cucumber-test')
end
