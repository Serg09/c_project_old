# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string           not null
#  first_name             :string           not null
#  last_name              :string           not null
#  phone_number           :string
#  contactable            :boolean          default(FALSE), not null
#  package_id             :integer
#  unsubscribed           :boolean          default(FALSE), not null
#  unsubscribe_token      :string(36)       not null
#

class User < ActiveRecord::Base
  has_many :bios, foreign_key: :author_id
  has_many :books, foreign_key: :author_id
  has_many :book_versions, through: :books, source: :versions
  has_many :campaigns, through: :books

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  validates_presence_of :first_name, :last_name, :username
  validates_uniqueness_of :username

  before_save :ensure_unsubscribe_token

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_bio
    bios.approved.by_date.first
  end

  def pending_bio
    bios.pending.by_date.first
  end

  def working_bio
    pending_bio || active_bio
  end

  def subscribed
    !unsubscribed
  end
  alias_method :subscribed?, :subscribed

  def subscribed=(subscribed)
    subscribed = false if subscribed == "0"
    self.unsubscribed = !subscribed
  end

  def pending_fulfillments
    Fulfillment.
      author(self).
      undelivered.
      ready
  end

  private

  def ensure_unsubscribe_token
    self.unsubscribe_token = SecureRandom.uuid unless unsubscribe_token
  end
end
