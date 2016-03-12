class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.integer :book_id
      t.decimal :target_amount
      t.date :target_date
      t.boolean :paused

      t.timestamps null: false
      t.index :book_id
    end
  end
end
