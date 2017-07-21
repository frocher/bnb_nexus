class UserMailer < ApplicationMailer
  def up(user, page, duration)
    mail(to: user.email, subject: "The page #{page.url} is up", body: "The page #{page.url} is up again after a downtime of #{duration}.")
  end

  def down(user, page, error_message)
    mail(to: user.email, subject: "The page #{page.url} is down", body: "The page #{page.url} is down : #{error_message}")
  end

  def weekly_summary(user, title, context)
    @context = context
    data = { html_content_only: true }
    mail(to: user.email, subject: title, sparkpost_data: data)
  end
end
