class AddPublicKeyToContributions < ActiveRecord::Migration
  def up
    add_column :contributions, :public_key, :string
    Contribution.all.each do |contribution|
      contribution.update_attribute :public_key, SecureRandom.uuid
    end
    change_column :contributions, :public_key, :string, null: false, limit: 36
    add_index :contributions, :public_key, unique: true
  end

  def down
    remove_column :contributions, :public_key
  end
end
