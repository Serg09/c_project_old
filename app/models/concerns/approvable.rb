# Manages the :status column for models that support approval
module Approvable
  extend ActiveSupport::Concern

  STATUSES = %w(pending approved rejected)

  STATUSES.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  module ClassMethods
    STATUSES.each do |status|
      define_method status.upcase do
        status
      end
    end
  end

  included do
    validates :status, presence: true, inclusion: { in: STATUSES }

    scope :pending, -> { where(status: Bio.PENDING).order('created_at DESC') }
    scope :approved, -> { where(status: Bio.APPROVED).order('created_at DESC') }
  end
end
