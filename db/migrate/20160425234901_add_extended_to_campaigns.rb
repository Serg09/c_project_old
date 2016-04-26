class AddExtendedToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :extended, :boolean, null: false, default: false
  end
end
