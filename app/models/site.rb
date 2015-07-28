class Site < ActiveRecord::Base


  has_many :pages, dependent: :destroy

  #
  # Validations
  #
  validates :name, presence: true

end
