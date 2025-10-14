return unless Rails.env.production?

host = ENV["MAILER_HOST"] || ENV["APP_HOST"] || "api.big5-quest.com"

ActionMailer::Base.delivery_method   = :ses_v2
ActionMailer::Base.ses_v2_settings   = { region: ENV["AWS_REGION"] || "ap-northeast-1" }
ActionMailer::Base.default_url_options = { host: host, protocol: "https" }
ActionMailer::Base.asset_host        = ENV["MAILER_ASSET_HOST"] || "https://#{host}"
ActionMailer::Base.default           from: (ENV["MAIL_FROM"] || "no-reply@big5-quest.com")
ActionMailer::Base.perform_caching   = false
ActionMailer::Base.raise_delivery_errors = true
