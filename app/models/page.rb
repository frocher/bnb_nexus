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
  has_attached_file :screenshot,
    path: ":rails_root/screenshots/:id/:style/:filename",
    default_url: "/images/:style/missing.png",
    styles: { medium: "", thumb: "320x240#" },
    convert_options: {
      medium: '-resize "1024x" +repage -crop "1024x240+0+0" -gravity North'
    }


  has_many :page_members, dependent: :destroy

  #
  # Validations
  #
  validates :name, presence: true
  validates :url, url: true
  validates_attachment_content_type :screenshot, :content_type => /\Aimage/
  validates_attachment_file_name :screenshot, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment_size :screenshot, :in => 0.kilobytes..2000.kilobytes

  def as_json(options={})
    super({only: [:id,:name,:url,:created_at, :updated_at]}.merge(options || {}))
  end

  #
  # Generate a screenshot of all pages
  #
  def self.screenshot
    now = Time.new
    Page.all.each do |page|
      if !page.screenshot.exists? || page.screenshot_updated_at.nil? || (now - page.screenshot_updated_at) > 14400
        ScreenshotJob.perform_later(page.id)
      end
    end
  end

  #
  # Check statistics of all pages
  #
  def self.check
    Page.all.each do |page|
      CheckJob.perform_later(page.id)
    end
  end

  #
  # Check uptime of all pages
  #
  def self.uptime
    logger.error "************ hi *******"
    Page.all.each do |page|
      UptimeJob.perform_later(page.id)
    end
  end

end
