require 'json'
require 'net/http'

class CheckJob
  def call(job)
    Rails.logger.info "++++++++ Started CheckJob ++++++++"
    page_id = job.tags[0]
    CheckTask.enqueue(page_id)
    Rails.logger.info "++++++++ Ended CheckJob ++++++++"
  end
end
