class Measure < ActiveRecord::Base

  belongs_to :page

  #
  # Validations
  #
  validates :category, presence: true
  validates :value, presence: true
end
