class RelaxConstraintsOnPayments < ActiveRecord::Migration
  def up
    change_column :payments, :external_id, :string, null: true
  end

  def down
    change_column :payments, :external_id, :string, null: false
  end
end
