class CheckJob < ActiveJob::Base
  queue_as do
    # TODO replace with real code
    :check
  end

  def perform(page_id)
    logger.info "++++++++ Started CheckJob ++++++++"
    page = Page.find(page_id)
    unless page.nil?
      begin
        probes = Rails.application.config.probes
        probe = probes.sample
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
      rescue Influxer::MetricsError => error
        logger.error "Error for #{page.url}"
        logger.error error.to_s
      end
      CheckJob.set(wait: 1.hour).perform_later(page_id)
    end
    logger.info "++++++++ Ended CheckJob ++++++++"
  end

end
