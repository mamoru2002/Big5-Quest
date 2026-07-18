return unless Rails.env.production?

host = ENV["MAILER_HOST"].presence || ENV["APP_HOST"].presence || "api.big5-quest.com"
delivery_method = (ENV["MAILER_DELIVERY_METHOD"].presence || "ses_v2").to_sym

ActionMailer::Base.delivery_method   = delivery_method
if delivery_method == :ses_v2
  ActionMailer::Base.ses_v2_settings = { region: ENV["AWS_REGION"].presence || "ap-northeast-1" }
end
ActionMailer::Base.default_url_options = { host: host, protocol: "https" }
ActionMailer::Base.asset_host        = ENV["MAILER_ASSET_HOST"].presence || "https://#{host}"
ActionMailer::Base.default           from: (ENV["MAIL_FROM"].presence || "no-reply@big5-quest.com")
ActionMailer::Base.perform_caching   = false
ActionMailer::Base.raise_delivery_errors = true
