return unless Rails.env.production?

host = ENV["MAILER_HOST"] || ENV["APP_HOST"] || "api.big5-quest.com"

Rails.application.config.action_mailer.default_url_options = {
  host: host, protocol: "https"
}
Rails.application.config.action_mailer.asset_host      = ENV["MAILER_ASSET_HOST"] || "https://#{host}"
Rails.application.config.action_mailer.delivery_method = :ses
Rails.application.config.action_mailer.perform_caching = false
Rails.application.config.action_mailer.raise_delivery_errors = true
Rails.application.config.action_mailer.default_options = {
  from: ENV["MAIL_FROM"] || "no-reply@big5-quest.com"
}
