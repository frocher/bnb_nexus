class ScreenshotJob

  # Update screenshots for pages without screenshots or that have shots older than 4 hours (14400 seconds)
  def call(job)
    page = Page.find(job.tags[0])
    now = Time.new
    if !page.screenshot.exists? || page.screenshot_updated_at.nil? || (now - page.screenshot_updated_at > 14400)
      ScreenshotTask.enqueue(page.id)
    end

  end
end
