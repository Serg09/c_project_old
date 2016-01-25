class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :bio_id, null: false
      t.string :site, limit: 20, null: false
      t.string :url, limit: 255, null: false

      t.timestamps null: false
    end
  end
end
