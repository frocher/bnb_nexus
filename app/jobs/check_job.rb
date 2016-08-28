class CheckJob < BaseJob
  queue_as do
    :check
  end

  def check(page, target)
    if page.last_uptime_value == 0
      logger.info "Check not done because #{page.url} is down"
      return
    end

    begin
      probe = choose_probe
      res = launch_probe(probe, target, page)
      if res.is_a?(Net::HTTPSuccess)
        result = JSON.parse(res.body)
        stats = result["stats"]["default"]["statistics"]
        write_perfomance_metrics(probe, target, page, stats)
        resources = result["har"]["log"]["entries"]
        write_assets_metrics(probe, target, page, resources)
        logger.info "Success for #{page.url}"
      else
        logger.error "Error #{res.code} for url #{page.url}"
      end
    rescue Exception => e
      logger.error "Error for #{page.url}"
      logger.error e.to_s
    end
  end

  def launch_probe(probe, target, page)
    uri = URI.parse("http://#{probe['host']}:#{probe['port']}/check?url=#{page.url}&target=#{target}&token=#{probe['token']}")
    Net::HTTP::get_response(uri)
  end

  def write_perfomance_metrics(probe, target, page, stats)
    metric = PerformanceMetrics.new page_id: page.id, target: target, probe: probe["name"]
    metric.response_start = stats["responseStart"]["median"].to_i
    metric.first_paint    = stats["firstPaint"]["median"].to_i
    metric.speed_index    = stats["speedIndex"]["median"].to_i
    metric.dom_ready      = stats["domInteractive"]["median"].to_i
    metric.page_load_time = stats["pageLoadTime"]["median"].to_i
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
      mime_type = find_mime_type(content["mimeType"])
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

  def find_mime_type(mime_type)
    return "html" if mime_type.include? "text/html"
    return "js" if mime_type.include? "javascript" or mime_type.include? "/ecmascript"
    return "css" if mime_type.include? "text/css"
    return "image" if mime_type.include? "image/"
    return "font" if mime_type.include? "font-" or mime_type.include? "ms-font" or mime_type.include? "font/"

    logger.debug "Other mime type : " + mime_type.to_s

    return "other"
  end

end
