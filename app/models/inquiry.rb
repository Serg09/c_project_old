# == Schema Information
#
# Table name: inquiries
#
#  id         :integer          not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  email      :string           not null
#  body       :text             not null
#  archived   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Inquiry < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :email, :body
  validates_format_of :email, with: /\A[\w\._\+-]+@[\w\._]+\.[a-z]{2,6}\z/

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def full_name
    "#{first_name} #{last_name}"
  end
end
