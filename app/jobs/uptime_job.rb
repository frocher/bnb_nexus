class UptimeJob < ActiveJob::Base
  queue_as do
    # TODO replace with real code
    :uptime
  end

  def perform(page_id)
    logger.info "++++++++ Started UptimeJob ++++++++"
    page = Page.find(page_id)
    unless page.nil?
      begin
        probes = Rails.application.config.probes
        probe = probes.sample
        uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/uptime?url=#{page.url}")
        res = Net::HTTP::get_response(uri)
        result = JSON.parse(res.body)
        if res.code == "200" && result["status"] == "success"
          UptimeMetrics.write(page_id: page_id, value: 1)
          logger.info "Success for #{page.url}"
        else
          error_content = result["content"] || "empty"
          UptimeMetrics.write(page_id: page_id, value: 0, error_code: res.code, error_message: result["errorMessage"], error_content: error_content)
          logger.error "Error #{res.code} for url #{page.url}"
        end
      rescue Exception => e
        logger.error "Error for #{page.url}"
        logger.error e.to_s
      end
      UptimeJob.set(wait: 15.minutes).perform_later(page_id)
    end
    logger.info "++++++++ Ended UptimeJob ++++++++"
  end
end
