class AddPhotoIdToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :photo_id, :integer
  end
end
