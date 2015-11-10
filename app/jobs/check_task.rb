require 'json'
require 'net/http'

class CheckTask
  def self.enqueue(resource_id)
      Resque::Job.create(select_queue(), self, resource_id)
    end

  def self.select_queue
    # TODO replace with real code
    :check
  end

  def self.perform(page_id)
    Resque.logger.info "++++++++ Started CheckTask ++++++++"

    probes = Rails.application.config.probes
    probe = probes.sample

    page = Page.find(page_id)

    uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/check?url=#{page.url}")
    res = Net::HTTP::get_response(uri)
    result = JSON.parse(res.body)
    if res.is_a?(Net::HTTPSuccess)
      stats = result["stats"]["default"]["statistics"]
      response_start = stats["responseStart"]["median"].to_i
      first_paint    = stats["firstPaint"]["median"].to_i
      speed_index    = stats["speedIndex"]["median"].to_i
      dom_ready      = stats["domInteractive"]["median"].to_i
      page_load_time = stats["pageLoadTime"]["median"].to_i
      PerformanceMetrics.write(page_id: page_id, response_start: response_start, first_paint: first_paint, speed_index: speed_index, dom_ready: dom_ready, page_load_time: page_load_time)
      Resque.logger.info "Success for " + page.url
    else
      Resque.logger.error "Error #{res.code} for url #{page.url}"
    end

    Resque.logger.info "++++++++ Ended CheckTask ++++++++"
  end
end
