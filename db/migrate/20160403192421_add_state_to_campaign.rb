class AddStateToCampaign < ActiveRecord::Migration
  def up
    add_column :campaigns, :state, :string, null: false, default: 'paused'
    Campaign.connection.execute("UPDATE campaigns set state = 'active' where paused = false")
    remove_column :campaigns, :paused
  end

  def down
    add_column :campaigns, :paused, :boolean, null: false, default: true
    Campaign.connection.execute("UPDATE campaigns set paused = 'false' where state = 'active'")
    remove_column :campaigns, :state
  end
end
