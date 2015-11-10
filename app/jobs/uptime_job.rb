class UptimeJob
  def call(job)
    Rails.logger.info "++++++++ Started UptimeJob ++++++++"
    page_id = job.tags[0]
    UptimeTask.enqueue(page_id)
    Rails.logger.info "++++++++ Ended UptimeJob ++++++++"
  end
end
