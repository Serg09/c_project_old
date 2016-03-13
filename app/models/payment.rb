# == Schema Information
#
# Table name: payments
#
#  id          :integer          not null, primary key
#  donation_id :integer          not null
#  external_id :string           not null
#  state       :string           not null
#  content     :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Payment < ActiveRecord::Base
  validates_presence_of :donation_id, :external_id, :state, :content
end
