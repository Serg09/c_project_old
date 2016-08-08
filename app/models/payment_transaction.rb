# == Schema Information
#
# Table name: payment_transactions
#
#  id         :integer          not null, primary key
#  payment_id :integer          not null
#  intent     :string(20)       not null
#  state      :string(100)      not null
#  response   :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentTransaction < ActiveRecord::Base
  belongs_to :payment

  # void is not an intent you can set on a payment
  # but here it is used to reflect our intent to
  # void the authorization
  #
  # Maybe we should use a cleaner separation of the
  # PayPal terminology and our own here
  INTENTS = %w(sale refund)
  class << self
    INTENTS.each do |intent|
      define_method intent.upcase do
        intent
      end
    end
  end

  CREATE_STATES = %w(created approved failed canceled expired pending)
  REFUND_STATES = %w(completed pending failed)
  STATES = (CREATE_STATES + REFUND_STATES).uniq
  class << self
    STATES.each do |state|
      define_method state.upcase do
        state
      end
    end
  end

  validates_presence_of :payment_id, :intent, :state, :response
  validates_inclusion_of :intent, in: INTENTS

  STATES.each do |state|
    scope state, ->{where(state: state)}
  end
end
