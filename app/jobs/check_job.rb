require 'json'
require 'net/http'

class CheckJob
  def call(job)
    Rails.logger.info "++++++++ Started CheckJob ++++++++"

    probes = Rails.application.config.probes
    probe = probes.sample

    page_id = job.tags[0]
    page = Page.find(page_id)

    uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/check?url=#{page.url}")
    res = Net::HTTP::get_response(uri)
    result = JSON.parse(res.body)
    if res.is_a?(Net::HTTPSuccess)
      stats = result["stats"]["default"]["statistics"]
      response_start = stats["responseStart"]["median"]
      first_paint    = stats["firstPaint"]["median"]
      speed_index    = stats["speedIndex"]["median"]
      dom_ready      = stats["domInteractive"]["median"]
      page_load_time = stats["pageLoadTime"]["median"]
      PerformanceMetrics.write(page_id: page_id, response_start: response_start, first_paint: first_paint, speed_index: speed_index, dom_ready: dom_ready, page_load_time: page_load_time)
      Rails.logger.info "Success for " + page.url
    else
      Rails.logger.error "Error #{res.code} for url #{page.url}"
    end

    Rails.logger.info "++++++++ Ended CheckJob ++++++++"
  end
end
