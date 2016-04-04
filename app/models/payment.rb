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
  CREDIT_CARD_TYPES = [
    ['VISA', 'visa'],
    ['Mastercard', 'mastercard'],
    ['Discover', 'discover'],
    ['American Express', 'amex']
  ]

  belongs_to :donation

  validates_presence_of :donation_id, :external_id, :state, :content
  validates_uniqueness_of :external_id

  scope :approved, ->{where(state: 'approved')}
  scope :failed, ->{where(state: 'failed')}

  def paid?
    state == 'completed'
  end

  # Updates the content attribute and extracts values for
  # updating state and any other values that need to be
  # recorded in that table in a manner that can be queried.
  # This method saves the record using #save and returns the result
  def update_content(new_content)
    json = JSON.parse(new_content)
    self.content = new_content
    self.state = json['state']
    save
  end
end
