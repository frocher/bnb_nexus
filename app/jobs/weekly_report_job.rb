require 'ostruct'

class WeeklyReportJob
  include ActionView::Helpers::NumberHelper

  def call(job, time)
    Rails.logger.info "Starting job #{self.class.name}"
    perform
  end

  def perform
    users = User.all
    users.each do |user|
      process_user(user)
    end
  end

  def process_user(user)
    Rails.logger.info "Processing user : " + user.email

    pages = user.pages.sort_by { |p| p["name"] }
    unless pages.empty?
      @context = OpenStruct.new
      @context.pages = []
      @context.period_start = (Date.today - 7).at_beginning_of_week.beginning_of_day
      @context.period_end = (Date.today - 7).at_end_of_week.end_of_day

      pages.each do |page|
        @context.pages << construct_page(page, @context.period_start, @context.period_end)
      end

      send_mail(user, generate_title(@context.period_start, @context.period_end))
    end
  rescue Exception => e
    Rails.logger.error "Error processing user " + user.email
    Rails.logger.error e.to_s
  end

  def generate_title(start_date, end_date)
    "Botnbot weekly report " + start_date.strftime("%m/%d/%Y") + " to " + end_date.strftime("%m/%d/%Y")
  end

  def send_mail(user, title)
    UserMailer.weekly_summary(user, title, @context).deliver_now
  rescue Exception => e
    Rails.logger.error "Error sending mail to user " + user.email
    Rails.logger.error e.to_s
  end

  def construct_page(page, start_date, end_date)
    Rails.logger.info "Processing page : " + page.name

    stats = OpenStruct.new
    stats.name = page.name

    uptime_summary  = page.uptime_summary(start_date, end_date)
    perf_summary  = page.performance_summary("desktop", start_date, end_date)
    req_summary   = page.requests_summary("desktop", start_date, end_date)
    bytes_summary = page.bytes_summary("desktop", start_date, end_date)

    stats.empty = uptime_summary.nil? || perf_summary.nil? || req_summary.nil? || bytes_summary.nil?

    unless stats.empty
      stats.uptime       = extract_value(uptime_summary, "value", 0, :*, 100)
      stats.speed_index  = extract_value(perf_summary, "speed_index", 0)
      stats.assets_count = sum_assets(req_summary)
      stats.assets_size  = sum_assets(bytes_summary) / 1024

      construct_previous(page, stats, start_date, end_date)
      construct_details(page, stats, start_date, end_date)
    end

    stats
  end

  def construct_previous(page, stats, start_date, end_date)
    previous_start = start_date - 1.week.to_i
    previous_end = end_date - 1.week.to_i

    previous_perf = page.performance_summary("desktop", previous_start, previous_end)

    stats.last_speed_index = extract_value(previous_perf, "speed_index", 0)
    stats.speed_index_delta = compute_delta(stats.speed_index, stats.last_speed_index)

    previous_uptime = page.uptime_summary(previous_start, previous_end)
    stats.last_uptime = extract_value(previous_uptime, "value", 0, :*, 100)
    stats.uptime_delta = stats.uptime - stats.last_uptime

    previous_req = page.requests_summary("desktop", previous_start, previous_end)
    stats.last_assets_count = sum_assets(previous_req)
    stats.assets_count_delta = compute_delta(stats.assets_count, stats.last_assets_count)

    previous_bytes = page.bytes_summary("desktop", previous_start, previous_end)
    stats.last_assets_size = sum_assets(previous_bytes) / 1024
    stats.assets_size_delta = compute_delta(stats.assets_size, stats.last_assets_size)
  end

  def sum_assets(assets)
    extract_value(assets, "html", 0) + extract_value(assets, "js", 0) + extract_value(assets, "css", 0) + extract_value(assets, "image", 0) + extract_value(assets, "font", 0) + extract_value(assets, "other", 0)
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
    stats.uptimes << extract_value(current_uptime, "value", "N/A", :*, 100)
  end

  def construct_performances(page, stats, current_day)
    current_perf = page.performance_summary("desktop", current_day.beginning_of_day, current_day.end_of_day)
    stats.response_times << extract_value(current_perf, "response_start", "N/A")
    stats.first_paints   << extract_value(current_perf, "first_paint", "N/A")
    stats.speed_indexes  << extract_value(current_perf, "speed_index", "N/A")
    stats.page_loads     << extract_value(current_perf, "page_load", "N/A")
  end

  def construct_requests(page, stats, current_day)
    current_req = page.requests_summary("desktop", current_day.beginning_of_day, current_day.end_of_day)
    stats.html_requests  << extract_value(current_req, "html", "N/A")
    stats.js_requests    << extract_value(current_req, "js", "N/A")
    stats.css_requests   << extract_value(current_req, "css", "N/A")
    stats.image_requests << extract_value(current_req, "image", "N/A")
    stats.font_requests  << extract_value(current_req, "font", "N/A")
    stats.other_requests << extract_value(current_req, "other", "N/A")
  end

  def construct_bytes(page, stats, current_day)
    current_bytes = page.bytes_summary("desktop", current_day.beginning_of_day, current_day.end_of_day)
    stats.html_bytes  << extract_value(current_bytes, "html", "N/A", :/, 1024)
    stats.js_bytes    << extract_value(current_bytes, "js", "N/A", :/, 1024)
    stats.css_bytes   << extract_value(current_bytes, "css", "N/A", :/, 1024)
    stats.image_bytes << extract_value(current_bytes, "image", "N/A", :/, 1024)
    stats.font_bytes  << extract_value(current_bytes, "font", "N/A", :/, 1024)
    stats.other_bytes << extract_value(current_bytes, "other", "N/A", :/, 1024)
  end

  def extract_value(array, column, default, operator = nil, operand = nil)
    if array.nil? || array[column].nil?
      default
    else
      if operator.nil?
        array[column]
      else
        array[column].send(operator, operand)
      end
    end
  end
end
