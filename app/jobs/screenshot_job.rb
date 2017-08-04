require 'open3'

class ScreenshotJob

  def call(job, time)
    page_id = job.opts[:page_id]
    Rails.logger.info "Starting job #{self.class.name} for page #{page_id}"
    perform(page_id)
  end

  def perform(page_id)
    ActiveRecord::Base.connection_pool.with_connection do
      if Page.exists?(page_id)
        page = Page.find(page_id)
        begin
          output_path = File.join(Rails.root, 'screenshots', page.id.to_s, 'original', page.id.to_s + '.png')
          file = File.join(Rails.root, 'app', 'phantom', 'screenshot.js')
          cmd = 'phantomjs --ssl-protocol=any ' + file + " " + page.url + " " + output_path + " 1024px*768px"
          stdout,stderr,status = Open3.capture3(cmd)
          if status.success?
            output_file = File.new output_path
            page.screenshot = output_file
            page.save!
            output_file.close
            Rails.logger.info "Success for #{page.url}"
          else
            Rails.logger.error "Error for #{page.url}"
            Rails.logger.error stdout
            Rails.logger.error stderr
          end
        rescue Exception => e
          Rails.logger.error "Error for #{page.url}"
          Rails.logger.error e.to_s
        end
      end
    end
  end

end
