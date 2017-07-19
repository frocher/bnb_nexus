class DesktopCheckJob < CheckJob

  def perform(page_id)
    if Page.exists?(page_id)
      page = Page.find(page_id)
      check(page, "desktop")
    end
  end

end
