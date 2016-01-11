class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.text :body, null: false
      t.boolean :archived, null: false, default: false

      t.timestamps null: false
    end
  end
end
