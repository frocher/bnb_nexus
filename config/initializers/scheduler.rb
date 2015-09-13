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
def counter = 1;
Page.all.each do |mypage|
  s.every '1m', UptimeJob, tag: mypage.id, first_at: Time.now + counter * 10
  counter += 1
end
