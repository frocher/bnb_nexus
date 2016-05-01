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
#  uptime_keyword          :string
#  uptime_keyword_type     :string
#  slack_webhook           :string
#  slack_channel           :string
#  mail_notify             :boolean          default(TRUE)
#  slack_notify            :boolean          default(FALSE)
#

class Page < ActiveRecord::Base
  after_create :init_jobs

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
  do_not_validate_attachment_file_type :screenshot
  validates :slack_webhook, url: true, if: Proc.new { |a| a.slack_notify? }
  validates :slack_channel, presence: true, if: Proc.new { |a| a.slack_notify? }

  def as_json(options={})
    h = super({only: [:id, :name, :url, :uptime_keyword, :uptime_keyword_type, :mail_notify, :slack_notify, :slack_webhook, :slack_channel, :created_at, :updated_at]}.merge(options || {}))
    h[:uptime_status] = last_uptime
    h
  end

  def last_uptime
    result = UptimeMetrics.select("last(value) as value").by_page(id)
    records = result.load
    records.empty? ? -1 : records[0]["value"]
  end

  def last_measure
    result = UptimeMetrics.select("value").by_page(id)
    records = result.load
    records.empty? ? nil : DateTime.parse(records.last["time"]).to_time
  end

  def init_jobs
    ScreenshotJob.set(wait: rand(1..60).minutes).perform_later(id)
    DesktopCheckJob.set(wait: rand(1..120).minutes).perform_later(id)
    MobileCheckJob.set(wait: rand(1..120).minutes).perform_later(id)
    UptimeJob.set(wait: rand(1..60).minutes).perform_later(id)
  end

end
