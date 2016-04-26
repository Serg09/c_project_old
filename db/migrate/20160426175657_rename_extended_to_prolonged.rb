class RenameExtendedToProlonged < ActiveRecord::Migration
  def change
    rename_column :campaigns, :extended, :prolonged
  end
end
