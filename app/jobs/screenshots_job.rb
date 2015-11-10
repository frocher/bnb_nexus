class ScreenshotsJob

  # Update screenshots for pages without screenshots or that have shots older than 4 hours (14400 seconds)
  # We only process 5 new screenshots per job
  def call(job)
    updated = 0
    now = Time.new
    Page.all.each do |page|
      if !page.screenshot.exists? || page.screenshot_updated_at.nil? || (now - page.screenshot_updated_at > 14400)
        ScreenshotsTask.enqueue(page.id)
        break if updated > 5
        updated += 1
      end
    end
  end
end
