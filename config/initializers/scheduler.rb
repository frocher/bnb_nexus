require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
scheduler = Rufus::Scheduler.singleton

def scheduler.on_error(job, error)
  Rails.logger.error(
    "err#{error.object_id} rufus-scheduler intercepted #{error.inspect}" +
    " in job #{job.inspect}")
  error.backtrace.each_with_index do |line, i|
    Rails.logger.error(
      "err#{error.object_id} #{i}: #{line}")
  end
end

# Run weekly report every monday at 1am
scheduler.cron('0 1 * * 1', WeeklyReportJob.new)

# Create jobs
Page.all.each do |page|
  page.init_jobs
end
