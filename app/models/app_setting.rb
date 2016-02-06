class AppSetting < ActiveRecord::Base
  def self.app_setting_value(name)
    name = name.to_s.chomp('?')
    Rails.cache.fetch("app_setting:#{name}", expires_in: 1.hour) do
      find_by(name: name).try(:typed_value)
    end
  end

  def self.method_missing(method_name, *args, &block)
    value = app_setting_value(method_name)
    return value if value || well_known_setting_name?(method_name)

    super
  end

  def typed_value
    case data_type
    when 'boolean'
      value.downcase == 'true'
    else
      Rails.logger.warn "Unrecognized data type #{app_setting.data_type} for setting #{app_setting.name}"
      nil
    end
  end

  def self.well_known_setting_name?(name)
    %w(sign_in_disabled).include? name.to_s.chomp('?')
  end
end
