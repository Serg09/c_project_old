class ExtractFulfillments < ActiveRecord::Migration
  def up
    Donation.where('reward_id is not null').each do |donation|
      if donation.reward.physical_address_required
        PhysicalFulfillment.create! donation_id: donation.id,
                                    reward_id: donation.reward_id,
                                    address1: donation.address.line1,
                                    address2: donation.address.line2,
                                    city: donation.address.city,
                                    state: donation.address.state,
                                    postal_code: donation.address.postal_code,
                                    country_code: donation.address.country_code,
                                    email: donation.email
      else
        ElectronicFulfillment.create! donation_id: donation.id,
                                      reward_id: donation.reward_id,
                                      email: donation.email
      end
    end

    remove_column :donations, :reward_id
  end

  def down
    change_table :donations do |t|
      t.integer :reward_id
    end

    ElectronicFulfillment.all.each do |f|
      f.donation.reward_id = f.reward_id
      f.donation.save!
    end
    PhysicalFulfillment.all.each do |f|
      f.donation.reward_id = f.reward_id
      f.donation.save!
    end
  end
end
