class AddPaidToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :paid, :boolean, null: false, default: false
  end
end
