class AddStatusToBio < ActiveRecord::Migration
  def change
    add_column :bios, :status, :string, null: false, default: 'pending'
  end
end
