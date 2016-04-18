class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.integer :payment_id, null: false
      t.string :intent, null: false, limit: 20
      t.string :state, null: false, limit: 20
      t.text :response, null: false

      t.timestamps null: false
    end
  end
end
