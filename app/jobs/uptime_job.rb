require 'sparkpost'

class UptimeJob < BaseJob
  queue_as do
    :uptime
  end

  def perform(page_id)
    page = Page.find(page_id)
    unless page.nil?
      begin
        probe = choose_probe
        res = launch_probe(probe, page)
        result = JSON.parse(res.body)
        last = page.get_last_uptime
        if res.code == "200" && result["status"] == "success"
          UptimeMetrics.write!(page_id: page_id, probe: probe["name"], value: 1)
          send_up_mail(page) if last == 0
          logger.info "Success for #{page.url}"
        else
          error_content = result["content"] || "empty"
          UptimeMetrics.write!(page_id: page_id, probe: probe["name"], value: 0, error_code: res.code, error_message: result["errorMessage"], error_content: error_content)
          send_down_mail(page, result["errorMessage"]) if last == 1
          logger.error "Error #{res.code} for url #{page.url}"
        end
      rescue Exception => e
        logger.error "Error for #{page.url}"
        logger.error e.to_s
      end
      UptimeJob.set(wait: Rails.configuration.x.jobs.uptime_interval).perform_later(page_id)
    end
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

  def send_up_mail(page)
    send_mail(page, "Page #{page.url} is up", "The page #{page.url} is up again.")
  end

  def send_down_mail(page, error_message)
    send_mail(page, "Page #{page.url} is down", "The page #{page.url} is down : #{error_message}")
  end

  def send_mail(page, title, message)
    sp = SparkPost::Client.new()
    page.page_members.each do |member|
      user = member.user
      sp.transmission.send_message(user.email, 'jeeves.thebot@botnbot.com', title, message)
    end
  end
end
