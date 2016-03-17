class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :donation_id, null: false
      t.string :external_id, null: false
      t.string :state, null: false
      t.text :content, null: false

      t.timestamps null: false

      t.index :donation_id
      t.index :external_id
    end
  end
end
