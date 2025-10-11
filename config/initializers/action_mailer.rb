if Rails.env.production?
  Rails.application.config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST")
  }
  Rails.application.config.action_mailer.asset_host = "https://#{ENV.fetch("APP_HOST")}"

  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.smtp_settings = {
    address:        ENV.fetch("SMTP_ADDRESS", "email-smtp.ap-northeast-1.amazonaws.com"),
    port:           ENV.fetch("SMTP_PORT", 587),
    user_name:      ENV.fetch("SMTP_USERNAME"),
    password:       ENV.fetch("SMTP_PASSWORD"),
    authentication: :login,
    enable_starttls_auto: true
  }
end
