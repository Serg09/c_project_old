# == Schema Information
#
# Table name: payment_transactions
#
#  id         :integer          not null, primary key
#  payment_id :integer          not null
#  intent     :string(20)       not null
#  state      :string(20)       not null
#  response   :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentTransaction < ActiveRecord::Base
end
