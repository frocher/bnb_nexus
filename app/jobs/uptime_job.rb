class UptimeJob
  def call(job)
    page_id = job.tags[0]
    page = Page.find(page_id)
    file = File.join(Rails.root, 'app', 'phantom', 'uptime.js')
    cmd = 'phantomjs --ssl-protocol=any ' + file + " " + page.url
    stdout,stderr,status = Open3.capture3(cmd)
    if status.success?
      logger.info "*********** success for " + page_id.to_s
      logger.info stdout
    else
      logger.error stdout
      logger.error stderr
    end
  end
end
