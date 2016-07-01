# == Schema Information
#
# Table name: subscribers
#
#  id         :integer          not null, primary key
#  first_name :string(50)       not null
#  last_name  :string(50)       not null
#  email      :string(250)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subscriber < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :email
  validates_length_of [:first_name, :last_name], maximum: 50
  validates_length_of :email, maximum: 250, if: :email
  validates_format_of :email, with: /\A[0-9a-z\._]+@[0-9a-z\._]+\.[a-z]{2,4}\z/, if: :email
  validates_uniqueness_of :email

  before_validation :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email
  end
end
