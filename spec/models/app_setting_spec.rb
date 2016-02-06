require 'rails_helper'

RSpec.describe AppSetting, type: :model do
  let!(:login_disabled) { AppSetting.create!(name: 'login_disabled', value: 'true', data_type: 'boolean') }

  describe 'dynamic class attributes' do
    it 'return the strongly typed value of the setting with the same name' do
      expect(AppSetting.login_disabled).to be true
    end
    it 'of boolean type have a question mark alias' do
      expect(AppSetting.login_disabled?).to be true
    end
  end
end
