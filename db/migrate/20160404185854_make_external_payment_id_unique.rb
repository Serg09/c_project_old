class MakeExternalPaymentIdUnique < ActiveRecord::Migration
  def up
    remove_index :payments, :external_id
    add_index :payments, :external_id, unique: true
  end

  def down
    remove_index :payments, :external_id
    add_index :payments, :external_id, unique: false
  end
end
