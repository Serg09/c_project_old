# == Schema Information
#
# Table name: donations
#
#  id          :integer          not null, primary key
#  campaign_id :integer          not null
#  amount      :decimal(, )      not null
#  email       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ip_address  :string(15)       not null
#  user_agent  :string           not null
#

class Donation < ActiveRecord::Base
  belongs_to :campaign
  has_many :payments

  validates_presence_of :campaign_id, :email, :amount, :ip_address, :user_agent
  validates_numericality_of :amount, greater_than: 0
  validates_format_of :email, with: /\A^\w[\w_\.-]+@\w[\w_\.-]+\.[a-z]{2,}\z/i
  validates_format_of :ip_address, with: /\A\d{1,3}(\.\d{1,3}){3}\z/
end
