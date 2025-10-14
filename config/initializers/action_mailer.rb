return unless Rails.env.production?

Rails.application.configure do |config|
  host = ENV["MAILER_HOST"] || ENV["APP_HOST"] || "api.big5-quest.com"

  config.action_mailer.delivery_method = :ses_v2
  config.action_mailer.ses_v2_settings = {
    region: ENV["AWS_REGION"] || "ap-northeast-1"
  }

  config.action_mailer.default_url_options = { host: host, protocol: "https" }
  config.action_mailer.asset_host          = ENV["MAILER_ASSET_HOST"] || "https://#{host}"
  config.action_mailer.default_options     = { from: ENV["MAIL_FROM"] || "no-reply@big5-quest.com" }
  config.action_mailer.perform_caching     = false
  config.action_mailer.raise_delivery_errors = true
end
