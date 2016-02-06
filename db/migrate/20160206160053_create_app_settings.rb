class CreateAppSettings < ActiveRecord::Migration
  def change
    create_table :app_settings do |t|
      t.string :name, null: false, limit: 20
      t.string :value, null: false, limit: 256
      t.string :data_type, null: false, limit: 20

      t.timestamps null: false
    end
    add_index :app_settings, :name, unique: true
  end
end
