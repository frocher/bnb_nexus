class ScreenshotsTask

  def self.enqueue(resource_id)
      Resque::Job.create(select_queue(), self, resource_id)
    end

  def self.select_queue
    :screenshots
  end

  def self.perform(page_id)
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
    else
      Resque.logger.error stdout
      Resque.logger.error stderr
    end
  end
end
