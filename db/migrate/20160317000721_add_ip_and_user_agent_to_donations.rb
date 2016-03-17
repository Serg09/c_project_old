class AddIpAndUserAgentToDonations < ActiveRecord::Migration
  def change
    change_table(:donations) do |t|
      t.string :ip_address, null: false, limit: 15
      t.string :user_agent, null: false
    end
  end
end
