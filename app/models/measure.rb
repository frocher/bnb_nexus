# == Schema Information
#
# Table name: measures
#
#  id         :integer          not null, primary key
#  category   :string
#  value      :integer
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Measure < ActiveRecord::Base

  belongs_to :page

  #
  # Validations
  #
  validates :category, presence: true
  validates :value, presence: true
end
