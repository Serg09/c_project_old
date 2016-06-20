class AddAgreeToTermsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :agree_to_terms, :boolean
  end
end
