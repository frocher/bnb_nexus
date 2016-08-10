require 'sparkpost'
require 'ostruct'


class WeeklyReportJob < BaseJob
  include ActionView::Helpers::NumberHelper

  queue_as do
    :weekly
  end

  def self.planify_next
    next_time = (Date.today + 7).at_beginning_of_week.beginning_of_day
    WeeklyReportJob.set(wait_until: next_time).perform_later
  end

  def perform
    users = User.all
    users.each do |user|
      process_user(user)
    end
    WeeklyReportJob.planify_next
  end

  def process_user(user)
    file_path = Rails.root.join("app", "views", "mail.slim")
    logger.info "Processing user : " + user.email

    pages = user.pages.sort_by { |p| p["name"] }
    @context = OpenStruct.new
    @context.pages = []
    @context.period_start = (Date.today - 7).at_beginning_of_week.beginning_of_day
    @context.period_end = (Date.today - 7).at_end_of_week.end_of_day

    pages.each do |page|
      @context.pages << construct_page(page, @context.period_start, @context.period_end)
    end

    message = Slim::Template.new(file_path).render(self)
    send_mail(user, generate_title(@context.period_start, @context.period_end), message)
  rescue Exception => e
    logger.error "Error processing user " + user.email
    logger.error e.to_s
  end

  def generate_title(start_date, end_date)
    "Botnbot weekly report " + start_date.strftime("%m/%d/%Y") + " to " + end_date.strftime("%m/%d/%Y")
  end

  def send_mail(user, title, message)
    sp = SparkPost::Client.new()
    sp.transmission.send_message(user.email, 'jeeves.thebot@botnbot.com', title, message)
  rescue Exception => e
    logger.error "Error sending mail to user " + user.email
    logger.error e.to_s
  end

  def construct_page(page, start_date, end_date)
    stats = OpenStruct.new

    stats.name = page.name

    uptime_summary  = page.uptime_summary(start_date, end_date)
    perf_summary  = page.performance_summary("desktop", start_date, end_date)
    req_summary   = page.requests_summary("desktop", start_date, end_date)
    bytes_summary = page.bytes_summary("desktop", start_date, end_date)

    stats.empty = uptime_summary.empty? || perf_summary.empty? || req_summary.empty? || bytes_summary.empty?

    unless stats.empty
      stats.speed_index = perf_summary[0]["speed_index"]
      stats.assets_count = sum_assets(req_summary[0])
      stats.assets_size = sum_assets(bytes_summary[0]) / 1024
      stats.uptime = uptime_summary[0]["value"] * 100

      construct_previous(page, stats, start_date, end_date)
      construct_details(page, stats, start_date, end_date)
    end

    stats
  end

  def construct_previous(page, stats, start_date, end_date)
    previous_start = start_date - 1.week.to_i
    previous_end = end_date - 1.week.to_i

    previous_perf = page.performance_summary("desktop", previous_start, previous_end)
    if previous_perf.empty?
      stats.last_speed_index = nil
    else
      stats.last_speed_index = previous_perf[0]["speed_index"]
      stats.speed_index_delta = compute_delta(stats.speed_index, stats.last_speed_index)
    end

    previous_uptime = page.uptime_summary(previous_start, previous_end)
    if previous_uptime.empty?
      stats.last_uptime = nil
    else
      stats.last_uptime = previous_uptime[0]["value"] * 100
      stats.uptime_delta = stats.uptime - stats.last_uptime
    end

    previous_req = page.requests_summary("desktop", previous_start, previous_end)
    if previous_req.empty?
      stats.last_assets_count = nil
    else
      stats.last_assets_count = sum_assets(previous_req[0])
      stats.assets_count_delta = compute_delta(stats.assets_count, stats.last_assets_count)
    end

    previous_bytes = page.bytes_summary("desktop", previous_start, previous_end)
    if previous_bytes.empty?
      stats.last_assets_size = nil
    else
      stats.last_assets_size = sum_assets(previous_bytes[0]) / 1024
      stats.assets_size_delta = compute_delta(stats.assets_size, stats.last_assets_size)
    end
  end

  def sum_assets(assets)
    assets["html"] + assets["js"] + assets["css"] + assets["image"] + assets["font"] + assets["other"]
  end

  def compute_delta(new_value, last_value)
    last_value != 0 ? (new_value - last_value) * 100 / last_value : 0
  end

  def construct_details(page, stats, start_date, end_date)
    stats.uptimes         = []
    stats.response_times  = []
    stats.first_paints    = []
    stats.speed_indexes   = []
    stats.page_loads      = []
    stats.html_requests   = []
    stats.js_requests     = []
    stats.css_requests    = []
    stats.image_requests  = []
    stats.font_requests   = []
    stats.other_requests  = []
    stats.html_bytes      = []
    stats.js_bytes        = []
    stats.css_bytes       = []
    stats.image_bytes     = []
    stats.font_bytes      = []
    stats.other_bytes     = []
    current_day = start_date
    while current_day <= end_date
      construct_uptimes(page, stats, current_day)
      construct_performances(page, stats, current_day)
      construct_requests(page, stats, current_day)
      construct_bytes(page, stats, current_day)
      current_day += 1.day.to_i
    end
  end

  def construct_uptimes(page, stats, current_day)
    current_uptime = page.uptime_summary(current_day.beginning_of_day, current_day.end_of_day)
    if current_uptime.empty?
      stats.uptimes << "N/A"
    else
      stats.uptimes << current_uptime[0]["value"] * 100
    end
  end

  def construct_performances(page, stats, current_day)
    current_perf = page.performance_summary("desktop", current_day.beginning_of_day, current_day.end_of_day)
    if current_perf.empty?
      stats.response_times << "N/A"
      stats.first_paints << "N/A"
      stats.speed_indexes << "N/A"
      stats.page_loads << "N/A"
    else
      stats.response_times << current_perf[0]["response_start"]
      stats.first_paints << current_perf[0]["first_paint"]
      stats.speed_indexes << current_perf[0]["speed_index"]
      stats.page_loads << current_perf[0]["page_load"]
    end
  end

  def construct_requests(page, stats, current_day)
    current_req = page.requests_summary("desktop", current_day.beginning_of_day, current_day.end_of_day)
    if current_req.empty?
      stats.html_requests << "N/A"
      stats.js_requests << "N/A"
      stats.css_requests << "N/A"
      stats.image_requests << "N/A"
      stats.font_requests << "N/A"
      stats.other_requests << "N/A"
    else
      stats.html_requests << current_req[0]["html"]
      stats.js_requests << current_req[0]["js"]
      stats.css_requests << current_req[0]["css"]
      stats.image_requests << current_req[0]["image"]
      stats.font_requests << current_req[0]["font"]
      stats.other_requests << current_req[0]["other"]
    end
  end

  def construct_bytes(page, stats, current_day)
    current_bytes = page.bytes_summary("desktop", current_day.beginning_of_day, current_day.end_of_day)
    if current_bytes.empty?
      stats.html_bytes << "N/A"
      stats.js_bytes << "N/A"
      stats.css_bytes << "N/A"
      stats.image_bytes << "N/A"
      stats.font_bytes << "N/A"
      stats.other_bytes << "N/A"
    else
      stats.html_bytes << current_bytes[0]["html"] / 1024
      stats.js_bytes << current_bytes[0]["js"] / 1024
      stats.css_bytes << current_bytes[0]["css"] / 1024
      stats.image_bytes << current_bytes[0]["image"] / 1024
      stats.font_bytes << current_bytes[0]["font"] / 1024
      stats.other_bytes << current_bytes[0]["other"] / 1024
    end
  end

end
