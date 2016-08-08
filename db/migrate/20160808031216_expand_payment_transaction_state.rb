class ExpandPaymentTransactionState < ActiveRecord::Migration
  def up
    change_column :payment_transactions, :state, :string, limit: 100
  end

  def down
    change_column :payment_transactions, :state, :string, limit: 20
  end
end
