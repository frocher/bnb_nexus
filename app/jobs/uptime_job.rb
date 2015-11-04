require 'json'
require 'net/http'

class UptimeJob
  def call(job)
    probes = Rails.application.config.probes
    probe = probes.sample

    page_id = job.tags[0]
    page = Page.find(page_id)

    uri = URI.parse("http://#{probe[:host]}:#{probe[:port]}/uptime?url=#{page.url}")
    res = Net::HTTP::get_response(uri)
    Rails.logger.info res.body
    result = JSON.parse(res.body)
    if res.code == "200" && result["status"] == "success"
      Rails.logger.info "++++++++ success for " + page.url
    else
      Rails.logger.error "Error #{res.code} for url #{page.url}"
    end

  end
end
