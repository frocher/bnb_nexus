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
    interval = nbDays < 7 ? '1h' : '1d'
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
    interval = nbDays < 7 ? '1h' : '1d'
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
    interval = nbDays < 7 ? '1h' : '1d'
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
    interval = nbDays < 7 ? '1h' : '1d'
    data = AssetsMetrics.select(selectValue).by_page(page.id).by_target(target).where(time: start_date..end_date).time(interval).fill(:none)
    data.to_a
  end

  def get_uptime(page, start_date, end_date)
    result = [
      {"key" => "uptime", "summary" => 0, "values" => []}]
    data = read_uptime_summary(page, start_date, end_date)
    if data.length > 0
      result[0]["summary"] = data[0]["value"]
      result[0]["values"] = read_uptime_points(page, start_date, end_date)
    end
    result
  end

  def get_performance(page, target, start_date, end_date)
    result = [
      {"key" => "response_start", "summary" => 0, "values" => []},
      {"key" => "first_paint", "summary" => 0, "values" => []},
      {"key" => "speed_index", "summary" => 0, "values" => []},
      {"key" => "dom_ready", "summary" => 0, "values" => []},
      {"key" => "page_load", "summary" => 0, "values" => []}]
    data = read_performance_summary(page, target, start_date, end_date)
    if data.length > 0
      result[0]["summary"] = data[0]["response_start"]
      result[1]["summary"] = data[0]["first_paint"]
      result[2]["summary"] = data[0]["speed_index"]
      result[3]["summary"] = data[0]["dom_ready"]
      result[4]["summary"] = data[0]["page_load"]
      points = read_performance_points(page, target, start_date, end_date)
      points.each do |point|
        result[0]["values"].push({"time" => point["time"], "value" => point["response_start"]})
        result[1]["values"].push({"time" => point["time"], "value" => point["first_paint"]})
        result[2]["values"].push({"time" => point["time"], "value" => point["speed_index"]})
        result[3]["values"].push({"time" => point["time"], "value" => point["dom_ready"]})
        result[4]["values"].push({"time" => point["time"], "value" => point["page_load"]})
      end
    end
    result
  end

  def get_requests(page, target, start_date, end_date)
    result = create_assets_array
    data = read_requests_summary(page, target, start_date, end_date)
    if data.length > 0
      init_assets_summary(result, data)
      points = read_requests_points(page, target, start_date, end_date)
      init_assets_points(result, points)
    end
    result
  end

  def get_bytes(page, target, start_date, end_date)
    result = create_assets_array
    data = read_bytes_summary(page, target, start_date, end_date)
    if data.length > 0
      init_assets_summary(result, data)
      points = read_bytes_points(page, target, start_date, end_date)
      init_assets_points(result, points)
    end
    result
  end

  def create_assets_array
    [ {"key" => "html", "summary" => 0, "values" => []},
      {"key" => "css", "summary" => 0, "values" => []},
      {"key" => "js", "summary" => 0, "values" => []},
      {"key" => "image", "summary" => 0, "values" => []},
      {"key" => "font", "summary" => 0, "values" => []},
      {"key" => "other", "summary" => 0, "values" => []}]
  end

  def init_assets_summary(assets, data)
    assets[0]["summary"] = data[0]["html"]
    assets[1]["summary"] = data[0]["css"]
    assets[2]["summary"] = data[0]["js"]
    assets[3]["summary"] = data[0]["image"]
    assets[4]["summary"] = data[0]["font"]
    assets[5]["summary"] = data[0]["other"]
  end

  def init_assets_points(assets, points)
    points.each do |point|
      assets[0]["values"].push({"time" => point["time"], "value" => point["html"]})
      assets[1]["values"].push({"time" => point["time"], "value" => point["css"]})
      assets[2]["values"].push({"time" => point["time"], "value" => point["js"]})
      assets[3]["values"].push({"time" => point["time"], "value" => point["image"]})
      assets[4]["values"].push({"time" => point["time"], "value" => point["font"]})
      assets[5]["values"].push({"time" => point["time"], "value" => point["other"]})
    end
  end
end
