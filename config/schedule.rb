# Use this file to easily define all of your cron jobs.


every 15.minutes do
  runner "Page.uptime", :output => 'log/cron.log'
end

every 1.hour do
  runner "Page.check", :output => 'log/cron.log'
end

every 45.minutes do
  runner "Page.screenshot", :output => 'log/cron.log'
end
