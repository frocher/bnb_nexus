class CheckJob < BaseJob

  def self.schedule_next(delay, handler, page_id, target)
    probes = Rails.application.config.probes
    probe = probes.sample
    mutex_name = "check_#{probe['name']}"

    scheduler = Rufus::Scheduler.singleton
    scheduler.in(delay, handler, {:page_id => page_id, :probe => probe, :target => target, :mutex => mutex_name})
  end

  def call(job, time)
    page_id = job.opts[:page_id]
    probe = job.opts[:probe]
    target = job.opts[:target]
    Rails.logger.info "Starting job #{self.class.name}/#{target} for page #{page_id} on probe #{probe['name']}"
    perform(page_id, target, probe)
    CheckJob.schedule_next(Rails.configuration.x.jobs.check_interval, job.handler, page_id, target)
  end

  def perform(page_id, target, probe)
    if Page.exists?(page_id)
      page = Page.find(page_id)
      check(page, target, probe)
    end
  end

  def check(page, target, probe)
    if page.last_uptime_value == 0
      Rails.logger.info "Check not done because #{page.url} is down"
      return
    end

    begin
      res = launch_probe(probe, target, page)
      if res.is_a?(Net::HTTPSuccess)
        result = JSON.parse(res.body)
        stats = result["stats"]
        write_perfomance_metrics(probe, target, page, stats)
        resources = result["har"]["log"]["entries"]
        write_assets_metrics(probe, target, page, resources)
        Rails.logger.info "Success for #{page.url}"
      else
        Rails.logger.error "Error #{res.code} for url #{page.url}"
      end
    rescue Exception => e
      Rails.logger.error "Error for #{page.url}"
      Rails.logger.error e.to_s
    end
  end

  def launch_probe(probe, target, page)
    uri = URI.parse("http://#{probe['host']}:#{probe['port']}/check?url=#{page.url}&target=#{target}&token=#{probe['token']}")
    request = Net::HTTP::Get.new(uri.request_uri)
    response = Net::HTTP.start(uri.host, uri.port) {|http|
      http.read_timeout = 120
      http.request(request)
    }
    response
  end

  def launch_probe1(probe, target, page)
    uri = URI.parse("http://#{probe['host']}:#{probe['port']}/check?url=#{page.url}&target=#{target}&token=#{probe['token']}")
    Net::HTTP::get_response(uri)
  end

  def write_perfomance_metrics(probe, target, page, stats)
    metric = PerformanceMetrics.new page_id: page.id, target: target, probe: probe["name"]
    metric.response_start = stats["responseStart"].to_i
    metric.first_paint    = stats["firstPaint"].to_i
    metric.speed_index    = stats["speedIndex"].to_i
    metric.dom_ready      = stats["domInteractive"].to_i
    metric.page_load_time = stats["pageLoadTime"].to_i
    metric.write!
  end

  def write_assets_metrics(probe, target, page, resources)
    data = {}
    data["html_requests"]  = 0
    data["js_requests"]    = 0
    data["css_requests"]   = 0
    data["image_requests"] = 0
    data["font_requests"]  = 0
    data["other_requests"] = 0
    data["html_bytes"]     = 0
    data["js_bytes"]       = 0
    data["css_bytes"]      = 0
    data["image_bytes"]    = 0
    data["font_bytes"]     = 0
    data["other_bytes"]    = 0

    resources.each do |resource|
      content = resource["response"]["content"]
      mime_type = find_mime_type(resource["request"]["url"], content["mimeType"])
      data[mime_type + "_requests"] += 1
      data[mime_type + "_bytes"]    += content["size"]
    end

    metric = AssetsMetrics.new page_id: page.id, target: target, probe: probe["name"]
    metric.html_requests  = data["html_requests"]
    metric.js_requests    = data["js_requests"]
    metric.css_requests   = data["css_requests"]
    metric.image_requests = data["image_requests"]
    metric.font_requests  = data["font_requests"]
    metric.other_requests = data["other_requests"]
    metric.html_bytes  = data["html_bytes"]
    metric.js_bytes    = data["js_bytes"]
    metric.css_bytes   = data["css_bytes"]
    metric.image_bytes = data["image_bytes"]
    metric.font_bytes  = data["font_bytes"]
    metric.other_bytes = data["other_bytes"]
    metric.write!
  end

  def find_mime_type(url, mime_type)
    return "other" if mime_type.nil? or url.nil?
    return "html"  if mime_type.include?("text/html")
    return "js"    if mime_type.include?("javascript") or mime_type.include? "/ecmascript"
    return "css"   if mime_type.include?("text/css")
    return "image" if mime_type.include?("image/")
    return "font"  if mime_type.include?("font-") or mime_type.include?("ms-font") or mime_type.include?("font/")
    return "font"  if url.ends_with?(".woff") or url.ends_with?(".woff2")

    Rails.logger.debug "Other mime type : #{mime_type} for url #{url}"
    return "other"
  end

end
