class AddStateToDonations < ActiveRecord::Migration
  def up
    add_column :donations, :state, :string, null: false, default: 'pledged'
    Donation.connection.execute("update donations set state = 'collected' where paid = true")
    remove_column :donations, :paid
  end

  def down
    add_column :donations, :paid, :boolean, null: false, default: false
    Donation.connection.execute("update donations set paid = true where state = 'collected'")
    remove_column :donations, :state
  end
end
