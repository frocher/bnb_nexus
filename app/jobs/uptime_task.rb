require 'json'
require 'net/http'

class UptimeTask
  extend Resque::Plugins::Logger

  def self.enqueue(resource_id)
      Resque::Job.create(select_queue(), self, resource_id)
    end

  def self.select_queue
    # TODO replace with real code
    :uptime
  end

  def self.perform(page_id)
    logger.info "++++++++ Started UptimeTask ++++++++"

    probes = Rails.application.config.probes
    probe = probes.sample

    page = Page.find(page_id)

    uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/uptime?url=#{page.url}")
    res = Net::HTTP::get_response(uri)
    result = JSON.parse(res.body)
    if res.code == "200" && result["status"] == "success"
      UptimeMetrics.write(page_id: page_id, value: 1)
      Resque.logger.info "Success for #{page.url}"
    else
      error_content = result["content"] || "empty"
      UptimeMetrics.write(page_id: page_id, value: 0, error_code: res.code, error_message: result["errorMessage"], error_content: error_content)
      logger.error "Error #{res.code} for url #{page.url}"
    end

    logger.info "++++++++ Ended UptimeTask ++++++++"
  end
end
