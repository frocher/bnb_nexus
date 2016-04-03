class Pages::StatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = Page.find(params[:page_id])
    return not_found! unless can?(current_user, :read_page, @page)

    @start_date = Date.parse(params[:start]).beginning_of_day
    @end_date   = Date.parse(params[:end]).end_of_day

    result = {}
    result["uptime"] = get_uptime(@page, @start_date, @end_date)
    result["performance"] = {}
    result["performance"]["desktop"] = get_performance(@page, "desktop", @start_date, @end_date)
    result["performance"]["mobile"]  = get_performance(@page, "mobile", @start_date, @end_date)
    result["requests"] = {}
    result["requests"]["desktop"] = get_requests(@page, "desktop", @start_date, @end_date)
    result["requests"]["mobile"]  = get_requests(@page, "mobile", @start_date, @end_date)
    result["bytes"] = {}
    result["bytes"]["desktop"] = get_bytes(@page, "desktop", @start_date, @end_date)
    result["bytes"]["mobile"]  = get_bytes(@page, "mobile", @start_date, @end_date)

    render json: result
  end

  def read_uptime_summary(page, start_date, end_date)
    data = UptimeMetrics.select("mean(value) as value").by_page(page.id).where(time: start_date..end_date)
    data.to_a
  end

  def read_uptime_points(page, start_date, end_date)
    nbDays = (end_date - start_date).to_i / 86400
    interval = nbDays <= 1 ? '1h' : '1d'
    data = UptimeMetrics.select("mean(value) as value").by_page(page.id).where(time: start_date..end_date).time(interval).fill(:none)
    data.to_a
  end

  def read_performance_summary(page, target, start_date, end_date)
    selectValue = "median(dom_ready) as dom_ready," \
                  "median(first_paint) as first_paint," \
                  "median(page_load_time) as page_load," \
                  "median(response_start) as response_start," \
                  "median(speed_index) as speed_index"
    data = PerformanceMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date)
    data.to_a
  end

  def read_performance_points(page, target, start_date, end_date)
    selectValue = "mean(dom_ready) as dom_ready," \
                  "mean(first_paint) as first_paint," \
                  "mean(page_load_time) as page_load," \
                  "mean(response_start) as response_start," \
                  "mean(speed_index) as speed_index"

    nbDays = (end_date - start_date).to_i / 86400
    interval = nbDays <= 1 ? '1h' : '1d'
    data = PerformanceMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date).time(interval).fill(:none)
    data.to_a
  end

  def read_requests_summary(page, target, start_date, end_date)
    selectValue = "median(html_requests) as html," \
                  "median(js_requests) as js," \
                  "median(css_requests) as css," \
                  "median(image_requests) as image," \
                  "median(font_requests) as font," \
                  "median(other_requests) as other"
    data = AssetsMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date)
    data.to_a
  end

  def read_requests_points(page, target, start_date, end_date)
    selectValue = "median(html_requests) as html," \
                  "median(js_requests) as js," \
                  "median(css_requests) as css," \
                  "median(image_requests) as image," \
                  "median(font_requests) as font," \
                  "median(other_requests) as other"
    nbDays = (end_date - start_date).to_i / 86400
    interval = nbDays <= 1 ? '1h' : '1d'
    data = AssetsMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date).time(interval).fill(:none)
    data.to_a
  end

  def read_bytes_summary(page, target, start_date, end_date)
    selectValue = "median(html_bytes) as html," \
                  "median(js_bytes) as js," \
                  "median(css_bytes) as css," \
                  "median(image_bytes) as image," \
                  "median(font_bytes) as font," \
                  "median(other_bytes) as other"
    data = AssetsMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date)
    data.to_a
  end

  def read_bytes_points(page, target, start_date, end_date)
    selectValue = "median(html_bytes) as html," \
                  "median(js_bytes) as js," \
                  "median(css_bytes) as css," \
                  "median(image_bytes) as image," \
                  "median(font_bytes) as font," \
                  "median(other_bytes) as other"
    nbDays = (end_date - start_date).to_i / 86400
    interval = nbDays <= 1 ? '1h' : '1d'
    data = AssetsMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date).time(interval).fill(:none)
    data.to_a
  end

  def get_uptime(page, start_date, end_date)
    result = {}
    data = read_uptime_summary(page, start_date, end_date)
    if data.length > 0
      result["value"]  = data[0]["value"]
      result["points"] = read_uptime_points(page, start_date, end_date)
    else
      result["value"] = 0
      result["points"] = []
    end
    result
  end

  def get_performance(page, target, start_date, end_date)
    result = {}
    data = read_performance_summary(page, target, start_date, end_date)
    if data.length > 0
      result["response_start"] = data[0]["response_start"]
      result["first_paint"]    = data[0]["first_paint"]
      result["speed_index"]    = data[0]["speed_index"]
      result["dom_ready"]      = data[0]["dom_ready"]
      result["page_load"]      = data[0]["page_load"]
      result["points"]         = read_performance_points(page, target, start_date, end_date)
    else
      result["response_start"] = 0
      result["first_paint"]    = 0
      result["speed_index"]    = 0
      result["dom_ready"]      = 0
      result["page_load"]      = 0
      result["points"]         = []
    end
    result
  end

  def get_requests(page, target, start_date, end_date)
    result = {}
    data = read_requests_summary(page, target, start_date, end_date)
    if data.length > 0
      result["html"]   = data[0]["html"]
      result["css"]    = data[0]["css"]
      result["js"]     = data[0]["js"]
      result["image"]  = data[0]["image"]
      result["font"]   = data[0]["font"]
      result["other"]  = data[0]["other"]
      result["points"] = read_requests_points(page, target, start_date, end_date)
    else
      result["html"]   = 0
      result["css"]    = 0
      result["js"]     = 0
      result["image"]  = 0
      result["font"]   = 0
      result["other"]  = 0
      result["points"] = []
    end
    result
  end

  def get_bytes(page, target, start_date, end_date)
    result = {}
    data = read_bytes_summary(page, target, start_date, end_date)
    if data.length > 0
      result["html"]   = data[0]["html"]
      result["css"]    = data[0]["css"]
      result["js"]     = data[0]["js"]
      result["image"]  = data[0]["image"]
      result["font"]   = data[0]["font"]
      result["other"]  = data[0]["other"]
      result["points"] = read_bytes_points(page, target, start_date, end_date)
    else
      result["html"]   = 0
      result["css"]    = 0
      result["js"]     = 0
      result["image"]  = 0
      result["font"]   = 0
      result["other"]  = 0
      result["points"] = []
    end
    result
  end
end
