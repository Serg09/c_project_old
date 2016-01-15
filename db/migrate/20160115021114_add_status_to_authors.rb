class AddStatusToAuthors < ActiveRecord::Migration
  def change
    change_table :authors do |t|
      t.string :status, limit: 10, null: false, default: 'pending'
    end
  end
end
