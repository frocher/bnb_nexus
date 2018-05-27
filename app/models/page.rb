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
#  push_notify             :boolean          default(TRUE)
#

class Page < ActiveRecord::Base
  after_create :init_jobs

  has_attached_file :screenshot,
    path: ":rails_root/reports/screenshots/:id/:style/:filename",
    default_url: "/images/:style/missing.png",
    styles: { medium: "", thumb: "320x240#" },
    convert_options: {
      medium: '-resize "1024x" +repage -crop "1024x240+0+0" -gravity North'
    }

  has_many :budgets, dependent: :destroy
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
    super({only: [:id, :name, :url, :uptime_keyword, :uptime_keyword_type, :mail_notify, :slack_notify, :push_notify, :slack_webhook, :slack_channel, :uptime_status, :created_at, :updated_at]}.merge(options || {}))
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

  def lighthouse_summary(start_date, end_date)
    select_value = "median(pwa) as pwa," \
                   "median(performance) as performance," \
                   "median(accessibility) as accessibility," \
                   "median(best_practices) as best_practices," \
                   "median(seo) as seo," \
                   "median(ttfb) as ttfb," \
                   "median(first_meaningful_paint) as first_meaningful_paint," \
                   "median(first_interactive) as first_interactive," \
                   "median(speed_index) as speed_index"
    data = LighthouseMetrics.select(select_value).by_page(id).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def uptime_summary(start_date, end_date)
    data = UptimeMetrics.select("mean(value) as value").by_page(id).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def requests_summary(start_date, end_date)
    select_value = "median(html_requests) as html," \
                   "median(js_requests) as js," \
                   "median(css_requests) as css," \
                   "median(image_requests) as image," \
                   "median(font_requests) as font," \
                   "median(other_requests) as other"
    data = AssetsMetrics.select(select_value).by_page(id).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def bytes_summary(start_date, end_date)
    select_value = "median(html_bytes) as html," \
                   "median(js_bytes) as js," \
                   "median(css_bytes) as css," \
                   "median(image_bytes) as image," \
                   "median(font_bytes) as font," \
                   "median(other_bytes) as other"
    data = AssetsMetrics.select(select_value).by_page(id).where(time: start_date..end_date)
    convert_influx_result(data)
  end

  def init_jobs
    scheduler = Rufus::Scheduler.singleton
    max_start = Rails.configuration.x.jobs.screenshot_start
    scheduler.every(Rails.configuration.x.jobs.screenshot_interval, ScreenshotJob.new, {:page_id => id, :mutex => "screenshot", :first_in => "#{rand(1..max_start)}m"})

    max_start = Rails.configuration.x.jobs.uptime_start
    UptimeJob.schedule_next("#{rand(1..max_start)}m", UptimeJob.new, id, false)
    max_start = Rails.configuration.x.jobs.har_start
    HarJob.schedule_next("#{rand(1..max_start)}m", HarJob.new, id)
    max_start = Rails.configuration.x.jobs.lighthouse_start
    LighthouseJob.schedule_next("#{rand(1..max_start)}m", LighthouseJob.new, id)
  end

  private

  def convert_influx_result(records)
    array = records.to_a
    array.empty? ? nil : array[0]
  end
end
