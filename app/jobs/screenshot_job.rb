class ScreenshotJob

  def call(job, time)
    page_id = job.opts[:page_id]
    probes = Rails.application.config.probes
    probe = probes.sample
    Rails.logger.info "Starting job #{self.class.name} for page #{page_id} on probe #{probe['name']}"
    ActiveRecord::Base.connection_pool.with_connection do
      if Page.exists?(page_id)
        page = Page.find(page_id)
        perform(page, probe)
      end
    end
  end

  def perform(page, probe)
    begin
      res = launch_probe(probe, page)
      if res.is_a?(Net::HTTPSuccess)
        output_path = File.join(Rails.root, "reports/screenshots", page.id.to_s, "original", page.id.to_s + ".png")
        file = File.open(output_path, "wb")
        file.write(res.body)
        page.screenshot = file
        page.save!
        file.close
        Rails.logger.info "Success screenshot for #{page.id} : #{page.url}"
      else
        Rails.logger.error "Error screenshot #{res.code} for #{page.id} : #{page.url}"
      end
    rescue Exception => e
      Rails.logger.error "Error screenshot for #{page.id} : #{page.url}"
      Rails.logger.error e.to_s
    end
  end

  def launch_probe(probe, page)
    uri = URI.parse("http://#{probe['host']}:#{probe['port']}/screenshot?url=#{page.url}&token=#{probe['token']}")
    request = Net::HTTP::Get.new(uri.request_uri)
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = 120
      http.request(request)
    end
    response
  end
end
