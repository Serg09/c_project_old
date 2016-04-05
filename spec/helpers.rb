module Helpers
  def payment_capture_response(options = {})
    filename = "payment_capture_#{options[:state] || :completed}.json"
    path = Rails.root.join('spec', 'fixtures', 'files', filename)
    raw_result = File.read(path)
    hash = JSON.parse(raw_result, symbolize_names: true)
    OpenStruct.new(id: hash[:id], state: hash[:state], to_json: raw_result)
  end
end
