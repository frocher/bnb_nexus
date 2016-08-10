
if Sidekiq.server?
  require 'sidekiq/api'

  # Remove old jobs
  Sidekiq::Queue.all.each &:clear
  Sidekiq::RetrySet.new.clear
  Sidekiq::ScheduledSet.new.clear

  # Create new ones
  Page.all.each do |page|
    page.init_jobs
  end
  WeeklyReportJob.planify_next
end
