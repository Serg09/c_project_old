class AddLinksToBio < ActiveRecord::Migration
  def change
    change_table :bios do |t|
      t.text :links
    end
  end
end
