class ScreenshotJob < ActiveJob::Base
  queue_as :screenshot

  def perform(page_id)
    logger.info "++++++++ Started ScreenshotJob ++++++++"
    page = Page.find(page_id)
    unless page.nil?
      begin
        output_path = File.join(Rails.root, 'screenshots', page.id.to_s, 'original', page.id.to_s + '.png')
        file = File.join(Rails.root, 'app', 'phantom', 'screenshot.js')
        cmd = 'phantomjs --ssl-protocol=any ' + file + " " + page.url + " " + output_path + " 1024px*768px"
        stdout,stderr,status = Open3.capture3(cmd)
        if status.success?
          output_file = File.new output_path

          logger.info "Output path : " + output_path.to_s

          page.screenshot = output_file
          page.save!
          output_file.close
          logger.info "Success for #{page.url}"
        else
          logger.error "Error for #{page.url}"
          logger.error stdout
          logger.error stderr
        end
      rescue Exception => e
        logger.error "Error for #{page.url}"
        logger.error e.to_s
      end
      ScreenshotJob.set(wait: 1.hour).perform_later(page_id)
    end
    logger.info "++++++++ Ended ScreenshotJob ++++++++"
  end
end
