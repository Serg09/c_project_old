class AppSetting < ActiveRecord::Base
  def self.method_missing(method_name)
    app_setting = find_by(name: method_name.to_s.chomp('?'))
    return nil unless app_setting

    case app_setting.data_type
    when 'boolean'
      app_setting.value.downcase == 'true'
    else
      Rails.logger.warn "Unrecognized data type #{app_setting.data_type} for setting #{app_setting.name}"
      nil
    end
  end
end
