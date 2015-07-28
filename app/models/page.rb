class Page < ActiveRecord::Base

  belongs_to :site
  has_many :measures, dependent: :destroy


  #
  # Validations
  #
  validates :url, presence: true

end
