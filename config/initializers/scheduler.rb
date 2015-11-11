require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

def s.on_pre_trigger(job, trigger_time)
  Rails.logger.info "triggering job #{job.id}..."
end

def s.on_post_trigger(job, trigger_time)
  Rails.logger.info "triggered job #{job.id}."
end

# Prepare jobs launches
r = Random.new
Page.all.each do |page|
  s.schedule_every '1h', UptimeJob, tag: page.id, first_at: Time.now + r.rand(3600)
  s.schedule_every '15m', CheckJob, tag: page.id, first_at: Time.now + r.rand(3600)
  s.schedule_every '1h', ScreenshotJob, tag: page.id, first_at: Time.now + r.rand(3600)
end
