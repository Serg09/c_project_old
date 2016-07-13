class AddProviderFeeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :provider_fee, :decimal, precision: 9, scale: 2
  end
end
