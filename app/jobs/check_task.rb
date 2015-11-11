require 'json'
require 'net/http'

class CheckTask
  extend Resque::Plugins::Logger

  def self.enqueue(resource_id)
      Resque::Job.create(select_queue(), self, resource_id)
    end

  def self.select_queue
    # TODO replace with real code
    :check
  end

  def self.perform(page_id)
    @log_name = "check_worker.log"
    logger.info "++++++++ Started CheckTask ++++++++"

    probes = Rails.application.config.probes
    probe = probes.sample
    page = Page.find(page_id)

    uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/check?url=#{page.url}")
    res = Net::HTTP::get_response(uri)
    result = JSON.parse(res.body)
    if res.is_a?(Net::HTTPSuccess)
      stats = result["stats"]["default"]["statistics"]

      metric = PerformanceMetrics.new page_id: page_id
      metric.response_start = stats["responseStart"]["median"].to_i
      metric.first_paint    = stats["firstPaint"]["median"].to_i
      metric.speed_index    = stats["speedIndex"]["median"].to_i
      metric.dom_ready      = stats["domInteractive"]["median"].to_i
      metric.page_load_time = stats["pageLoadTime"]["median"].to_i
      metric.write!
      logger.info "Success for #{page.url}"
    else
      logger.error "Error #{res.code} for url #{page.url}"
    end

    logger.info "++++++++ Ended CheckTask ++++++++"
  rescue Influxer::MetricsError => error
    logger.error error.to_s
  end
end
