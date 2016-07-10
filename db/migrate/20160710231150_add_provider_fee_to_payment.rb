class AddProviderFeeToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :provider_fee, :decimal, scale: 2, precision: 9
  end
end
