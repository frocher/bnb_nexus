class UptimeJob < BaseJob

  def self.schedule_next(delay, handler, page_id, second_chance)
    probes = Rails.application.config.probes
    probe = probes.sample
    mutex_name = "uptime_#{probe['name']}"

    scheduler = Rufus::Scheduler.singleton
    scheduler.in(delay, handler, {:page_id => page_id, :is_second_chance => second_chance, :probe => probe, :mutex => mutex_name})
  end

  def call(job, time)
    page_id = job.opts[:page_id]
    probe = job.opts[:probe]
    Rails.logger.info "Starting job #{self.class.name} for page #{page_id} on probe #{probe['name']}"
    second_chance = perform(page_id, job.opts[:is_second_chance] || false, probe)
    delay = second_chance ? Rails.configuration.x.jobs.second_chanche_interval : Rails.configuration.x.jobs.uptime_interval
    UptimeJob.schedule_next(delay, job.handler, page_id, second_chance)
  end

  def perform(page_id, is_second_chance, probe)
    second_chance = false
    if Page.exists?(page_id)
      page = Page.find(page_id)
      begin
        res = launch_probe(probe, page)
        result = JSON.parse(res.body)
        last = page.last_uptime_value
        if res.code == "200" && result["status"] == "success"
          UptimeMetrics.write!(page_id: page_id, probe: probe["name"], value: 1)
          send_up_notification(page) if last == 0
          Rails.logger.info "Success for #{page.url}"
        else
          error_content = result["content"] || "empty"
          if is_second_chance
            UptimeMetrics.write!(page_id: page_id, probe: probe["name"], value: 0, error_code: res.code, error_message: result["errorMessage"], error_content: error_content)
            send_down_notification(page, result["errorMessage"]) if last == 1
          else
            second_chance = true
          end
          Rails.logger.error "Error #{res.code} for url #{page.url}, second chance is #{is_second_chance}"
        end
      rescue Exception => e
        Rails.logger.error "Bot error for #{page.url}"
        Rails.logger.error e.to_s
      end
    end
    second_chance
  end

  def launch_probe(probe, page)
    url = "http://#{probe['host']}:#{probe['port']}/uptime?url=#{page.url}&token=#{probe['token']}"
    if !page.uptime_keyword.nil? && page.uptime_keyword != ""
      type = page.uptime_keyword_type
      type = "presence" if type != "presence" && type != "absence"
      keyword = CGI::escape(page.uptime_keyword)
      url += "&keyword=#{keyword}&type=#{type}"
    end
    uri = URI.parse(url)
    Net::HTTP::get_response(uri)
  end

  private

  def send_up_notification(page)
    duration = page.last_downtime_duration
    if page.mail_notify
      send_up_mail(page, duration)
    end
    if page.slack_notify
      send_slack_message(page, "The page #{page.url} is up again after a downtime of #{duration}.")
    end
  end

  def send_down_notification(page, error_message)
    if page.mail_notify
      send_down_mail(page, error_message)
    end
    if page.slack_notify
      send_slack_message(page, "The page #{page.url} is down : #{error_message}")
    end
  end

  def send_down_mail(page, error_message)
    page.page_members.each do |member|
      user = member.user
      UserMailer.down(user, page, error_message).deliver_now
    end
  rescue Exception => e
    Rails.logger.error e.to_s
    e.backtrace.each { |line| Rails.logger.error line }
  end

  def send_up_mail(page, duration)
    page.page_members.each do |member|
      user = member.user
      UserMailer.up(user, page, duration).deliver_now
    end
  rescue Exception => e
    Rails.logger.error e.to_s
    e.backtrace.each { |line| Rails.logger.error line }
  end

  def send_slack_message(page, message)
    unless page.slack_webhook.nil? or page.slack_webhook.blank?
      notifier = Slack::Notifier.new page.slack_webhook, channel: page.slack_channel, username: "jeeves.thebot"
      notifier.ping message
    end
  rescue Exception => e
    Rails.logger.error e.to_s
  end
end
