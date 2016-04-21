class ExtractFulfillments < ActiveRecord::Migration
  def up
    donations = Donation.connection.execute('select * from donations where reward_id is not null;')
    donations.each do |donation|
      get_reward_sql = "select * from rewards where id = #{donation['reward_id']};"
      reward = Donation.connection.execute(get_reward_sql).first
      insert_sql = if reward['pysical_address_required']
                     sql = "SELECT pt.response from payment_transactions pt inner join payments p on p.id = pt.payment_id where p.donation_id = #{donation['id']} limit 1;"
                     record = Donation.connection.execute(sql).first
                     payment = JSON.parse(record['response'], symbolize_names: true)
                     address = payment[:payer][:funding_instruments][0][:credit_card][:billing_address]
                     "insert into fulfillments(type, donation_id, reward_id, address1, address2, city, state, postal_code, country_code, email, created_at, updated_at) values ('PhysicalFulfillment', #{donation['id']}, #{donation['reward_id']}, '#{address[:line1]}', #{address[:line2] ? ("'" + address[:line2] = "'") : "null"}, '#{address[:city]}', '#{address[:state]}', '#{address[:postal_code]}', '#{address[:country_code]}', '#{donation['email']}', '#{DateTime.now.to_formatted_s}', '#{DateTime.now.to_formatted_s}');"
                   else
                     "insert into fulfillments(type, donation_id, reward_id, email, created_at, updated_at) values ('ElectronicFulfillment', #{donation['id']}, #{donation['reward_id']}, '#{donation['email']}', '#{DateTime.now.to_formatted_s}', '#{DateTime.now.to_formatted_s}');"
                   end
      Donation.connection.execute(insert_sql)
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
