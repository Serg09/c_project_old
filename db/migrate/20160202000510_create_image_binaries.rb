class CreateImageBinaries < ActiveRecord::Migration
  def change
    create_table :image_binaries do |t|
      t.binary :data, null: false

      t.timestamps null: false
    end
  end
end
