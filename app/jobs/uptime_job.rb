require 'sparkpost'

class UptimeJob < ActiveJob::Base
  queue_as do
    # TODO replace with real code
    :uptime
  end

  def perform(page_id)
    logger.info "++++++++ Started UptimeJob ++++++++"
    page = Page.find(page_id)
    unless page.nil?
      begin
        probes = Rails.application.config.probes
        probe = probes.sample
        uri = URI.parse("http://#{probe['host']}:#{probe['port']}/uptime?url=#{page.url}&token=#{probe['token']}")
        res = Net::HTTP::get_response(uri)
        result = JSON.parse(res.body)
        last = get_last_value(page)
        if res.code == "200" && result["status"] == "success"
          UptimeMetrics.write(page_id: page_id, value: 1)
          send_up_mail(page) if last == 0
          logger.info "Success for #{page.url}"
        else
          error_content = result["content"] || "empty"
          UptimeMetrics.write(page_id: page_id, value: 0, error_code: res.code, error_message: result["errorMessage"], error_content: error_content)
          send_down_mail(page) if last == 1
          logger.error "Error #{res.code} for url #{page.url}"
        end
      rescue Exception => e
        logger.error "Error for #{page.url}"
        logger.error e.to_s
      end
      UptimeJob.set(wait: 15.minutes).perform_later(page_id)
    end
    logger.info "++++++++ Ended UptimeJob ++++++++"
  end

  private

  def get_last_value(page)
    result = UptimeMetrics.select("last(value) as value").by_page(page.id)
    records = result.load
    records[0][:value]
  end

  def send_up_mail(page)
    send_mail(page, "Site up", "Your site #{page.url} is up")
  end

  def send_down_mail(page)
    send_mail(page, "Site down", "Your site #{page.url} is down")
  end

  def send_mail(page, title, message)
    sp = SparkPost::Client.new()
    page.page_members.each do |member|
      user = member.user
      sp.transmission.send_message(user.email, 'jeeves@botnbot.com', title, message)
    end
  end
end
