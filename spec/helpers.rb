module Helpers
  def authorization_void_response(options = {})
    raise StandardError.new('Induced error') if options[:state] == :exception

    response_from_file "authorization_void_#{options[:state] || :voided}.json"
  end

  def payment_create_response(options = {})
    response_from_file "payment_create_#{options[:state] || :approved}.json"
  end

  def payment_capture_response(options = {})
    raise StandardError.new('Induced error') if options[:state] == :exception

    response_from_file "payment_capture_#{options[:state] || :completed}.json"
  end

  private

  def response_from_file(filename)
    path = Rails.root.join('spec', 'fixtures', 'files', filename)
    raw_result = File.read(path)
    hash = JSON.parse(raw_result, symbolize_names: true)
    OpenStruct.new(id: hash[:id], state: hash[:state], to_json: raw_result)
  end
end
