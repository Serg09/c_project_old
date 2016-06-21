class AdjustContributionConstraints < ActiveRecord::Migration
  def up
    change_column :contributions, :state, :string, null: false, default: 'incipient'
    change_column :contributions, :email, :string, null: true
  end

  def down
    change_column :contributions, :state, :string, null: false, default: 'pledged'
    change_column :contributions, :email, :string, null: false
  end
end
