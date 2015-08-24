# == Schema Information
#
# Table name: pages
#
#  id                      :integer          not null, primary key
#  name                    :string
#  url                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  screenshot_file_name    :string
#  screenshot_content_type :string
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#

class Page < ActiveRecord::Base
  has_attached_file :screenshot, styles: { medium: "1024x240#", thumb: "320x240#" }, default_url: "/images/:style/missing.png"

  has_many :measures, dependent: :destroy

  #
  # Validations
  #
  validates :name, presence: true
  validates :url, url: true
  validates_attachment_content_type :screenshot, :content_type => /\Aimage/
  validates_attachment_size :screenshot, :in => 0.kilobytes..500.kilobytes

  def medium_url
  	ApplicationController.helpers.asset_url(screenshot.url(:medium))
  end

  def thumb_url
  	screenshot.url(:thumb)
  end

  def as_json(options={})
    super(only: [:id,:name,:url,:created_at, :updated_at],
          methods: [:medium_url, :thumb_url])
  end
end
