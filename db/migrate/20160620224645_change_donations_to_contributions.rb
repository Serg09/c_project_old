class ChangeDonationsToContributions < ActiveRecord::Migration
  def change
    rename_table :donations, :contributions
    rename_column :fulfillments, :donation_id, :contribution_id
    rename_column :payments, :donation_id, :contribution_id
    rename_column :rewards, :minimum_donation, :minimum_contribution
  end
end
