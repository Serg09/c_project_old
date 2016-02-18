class AddSampleIdToBooks < ActiveRecord::Migration
  def change
    change_table :books do |t|
      t.integer :sample_id
    end
  end
end
