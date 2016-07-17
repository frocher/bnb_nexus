class MobileCheckJob < CheckJob

  def perform(page_id)
    if Page.exists?(page_id)
      page = Page.find(page_id)
      check(page, "mobile")
      MobileCheckJob.set(wait: Rails.configuration.x.jobs.check_interval).perform_later(page_id)
    end
  end

end
