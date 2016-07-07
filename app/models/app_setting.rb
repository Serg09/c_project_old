# == Schema Information
#
# Table name: app_settings
#
#  id         :integer          not null, primary key
#  name       :string(20)       not null
#  value      :string(256)      not null
#  data_type  :string(20)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppSetting < ActiveRecord::Base
  def self.app_setting_value(name)
    name = name.to_s.chomp('?')
    Rails.cache.fetch("app_setting:#{name}", expires_in: cache_duration) do
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

  private

  def self.cache_duration
    @cache_duration ||= (ENV['APP_SETTING_CACHE_MINUTES'] || 1).to_i
  end
end
