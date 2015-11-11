class ScreenshotTask
  extend Resque::Plugins::Logger

  def self.enqueue(resource_id)
      Resque::Job.create(select_queue(), self, resource_id)
    end

  def self.select_queue
    :screenshot
  end

  def self.perform(page_id)
    @log_name = "screenshot_worker.log"
    logger.info "++++++++ Started ScreenshotTask ++++++++"

    page = Page.find(page_id)
    output_path = File.join(Rails.root, 'screenshots', page.id.to_s, 'original', page.id.to_s + '.png')
    file = File.join(Rails.root, 'app', 'phantom', 'screenshot.js')
    cmd = 'phantomjs --ssl-protocol=any ' + file + " " + page.url + " " + output_path + " 1024px*768px"
    stdout,stderr,status = Open3.capture3(cmd)
    if status.success?
      output_file = File.new output_path
      page.screenshot = output_file
      page.save
      output_file.close
      logger.info "Success for #{page.url}"
    else
      logger.error "Error for #{page.url}"
      logger.error stdout
      logger.error stderr
    end
    logger.info "++++++++ Ended ScreenshotTask ++++++++"
  end
end
