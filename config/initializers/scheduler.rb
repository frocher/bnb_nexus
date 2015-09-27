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

# Screenshots task...
s.every '1h', ScreenshotsJob

# Uptime task
r = Random.new
Page.all.each do |mypage|
  delta = r.rand(300)
  s.every '5m', UptimeJob, tag: mypage.id, first_at: Time.now + delta
end
