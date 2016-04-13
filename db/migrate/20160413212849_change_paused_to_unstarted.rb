class ChangePausedToUnstarted < ActiveRecord::Migration
  def up
    change_column :campaigns, :state, :string, null: false, limit: 20, default: 'unstarted'
  end

  def down
    change_column :campaigns, :state, :string, null: false, default: 'paused'
  end
end
