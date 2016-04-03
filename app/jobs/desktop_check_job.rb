class DesktopCheckJob < CheckJob

  def perform(page_id)
    page = Page.find(page_id)
    unless page.nil?
      check(page, "desktop")
      DesktopCheckJob.set(wait: 1.hour).perform_later(page_id)
    end
  end

end
