RSpec::Matchers.define :be_close_to do |expected, tolerance = 0.1|
  match do |actual|
    diff = (actual - expected).abs
    percent_diff = diff / expected
    percent_diff <= tolerance
  end

  failure_message do |actual|
    "expected #{actual} to be closer to #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual} not to be close to #{expected}"
  end

  description do
    "be close to #{expected}"
  end
end
