class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.integer :campaign_id, null: false
      t.decimal :amount, null: false
      t.string :email, null: false

      t.timestamps null: false
      t.index :campaign_id
      t.index :email
    end
  end
end
