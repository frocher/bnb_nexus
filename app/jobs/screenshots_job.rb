class ScreenshotsJob

  # Update screenshots for pages without screenshots or that have shots older than 4 hours (14400 seconds)
  # We only process 5 new screenshots per job
  def call(job)
    updated = 0
    now = Time.new
    Page.all.each do |page|
      if !page.screenshot.exists? || page.screenshot_updated_at.nil? || (now - page.screenshot_updated_at > 14400)
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
          logger.error stdout
          logger.error stderr
        end

        break if updated > 5
        updated += 1
      end
    end
  end
end
