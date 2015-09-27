require 'net/http'

class UptimeJob
  def call(job)
    probes = Rails.application.config.probes
    probe = probes.sample

    page_id = job.tags[0]
    page = Page.find(page_id)

    url = URI.parse("http://#{probe[:host]}:#{probe[:port]}/uptime?url=#{page.url}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    Rails.logger.info "*********** success for " + page.url
    Rails.logger.info res.body

  end
end
