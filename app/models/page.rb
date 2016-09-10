require 'chronic_duration'

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
    h[:uptime_status] = last_uptime_value
    h
  end

  def last_uptime_value
    result = UptimeMetrics.select("last(value) as value").by_page(id)
    records = result.load
    records.empty? ? -1 : records[0]["value"]
  end

  def last_downtime_duration
    result = UptimeMetrics.select("value").by_page(id)
    records = result.load
    return 0 if records.empty?

    found_down = nil
    found_up = nil
    last_down = 0
    last_up = 0
    records.reverse_each do |record|
      if record["value"] == 1
        last_up = DateTime.parse(record["time"]).to_time

        # If we have a up and we previously found a down, we can now compute the duration
        unless found_down.nil?
          # Never had a up, so the page is currently down. We use time now for compute
          if found_up.nil?
            found_up = Time.now
          end
          interval = found_up.round(0) - last_down.round(0)
          return ChronicDuration.output(interval, :format => :long)
        end
      else
        last_down = DateTime.parse(record["time"]).to_time
        if found_down.nil?
          found_up = last_up
          found_down = last_down
        end
      end
    end
  end

  def uptime_summary(start_date, end_date)
    data = UptimeMetrics.select("mean(value) as value").by_page(id).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def performance_summary(target, start_date, end_date)
    selectValue = "median(dom_ready) as dom_ready," \
                  "median(first_paint) as first_paint," \
                  "median(page_load_time) as page_load," \
                  "median(response_start) as response_start," \
                  "median(speed_index) as speed_index"
    data = PerformanceMetrics.select(selectValue).by_page(id).by_target(target).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def requests_summary(target, start_date, end_date)
    selectValue = "median(html_requests) as html," \
                  "median(js_requests) as js," \
                  "median(css_requests) as css," \
                  "median(image_requests) as image," \
                  "median(font_requests) as font," \
                  "median(other_requests) as other"
    data = AssetsMetrics.select(selectValue).by_page(id).by_target(target).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def bytes_summary(target, start_date, end_date)
    selectValue = "median(html_bytes) as html," \
                  "median(js_bytes) as js," \
                  "median(css_bytes) as css," \
                  "median(image_bytes) as image," \
                  "median(font_bytes) as font," \
                  "median(other_bytes) as other"
    data = AssetsMetrics.select(selectValue).by_page(id).by_target(target).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def init_jobs
    ScreenshotJob.set(wait: rand(1..60).minutes).perform_later(id)
    DesktopCheckJob.set(wait: rand(1..120).minutes).perform_later(id)
    MobileCheckJob.set(wait: rand(1..120).minutes).perform_later(id)
    UptimeJob.set(wait: rand(1..60).minutes).perform_later(id, false)
  end

  private

  def convert_influx_result(records)
    array = records.to_a
    array.empty? ? nil : array[0]
  end
end
