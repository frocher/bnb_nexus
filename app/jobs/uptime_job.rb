require 'json'
require 'net/http'

class UptimeJob
  def call(job)
    Rails.logger.info "++++++++ Started UptimeJob ++++++++"

    probes = Rails.application.config.probes
    probe = probes.sample

    page_id = job.tags[0]
    page = Page.find(page_id)

    uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/uptime?url=#{page.url}")
    res = Net::HTTP::get_response(uri)
    result = JSON.parse(res.body)
    if res.code == "200" && result["status"] == "success"
      UptimeMetrics.write(page_id: page_id, value: 1)
      Rails.logger.info "Success for " + page.url
    else
      error_content = result["content"] || "empty"
      UptimeMetrics.write(page_id: page_id, value: 0, error_code: res.code, error_message: result["errorMessage"], error_content: error_content)
      Rails.logger.error "Error #{res.code} for url #{page.url}"
    end

    Rails.logger.info "++++++++ Ended UptimeJob ++++++++"
  end
end
