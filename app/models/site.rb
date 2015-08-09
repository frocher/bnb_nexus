class Site < ActiveRecord::Base
  has_attached_file :screenshot, styles: { medium: "1024x240#", thumb: "320x240#" }

  has_many :pages, dependent: :destroy

  #
  # Validations
  #
  validates :name, presence: true
  validates_attachment_content_type :attachment, :content_type => /\Aimage/
  validates_attachment_size :attachment, :in => 0.kilobytes..500.kilobytes

end
