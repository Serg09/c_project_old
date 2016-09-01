# Manages the :status column for models that support approval
module Approvable
  extend ActiveSupport::Concern

  STATUSES = %w(Pending Approved Rejected Superceded)
  def supersede_current
    current_version.supersede! if current_version
  end

  included do
    include AASM

    aasm(:status) do
      state :pending, initial: true
      state :approved
      state :rejected
      state :superseded

      event :approve do
        before { supersede_current }
        transitions from: :pending, to: :approved
      end

      event :reject do
        transitions from: :pending, to: :rejected
      end

      event :supersede do
        transitions from: :approved, to: :superseded
      end
    end

    scope :by_date, -> { order('created_at DESC') }
  end
end
