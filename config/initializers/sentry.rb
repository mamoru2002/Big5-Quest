Sentry.init do |config|
config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["SENTRY_ENV"] || Rails.env
  config.enabled_environments = %w[production]
  config.traces_sample_rate   = (ENV["SENTRY_TRACES_RATE"]   || 0).to_f
  config.profiles_sample_rate = (ENV["SENTRY_PROFILES_RATE"] || 0).to_f

  error_sample_rate = (ENV["SENTRY_ERROR_SAMPLE_RATE"] || "0.25").to_f

  config.send_default_pii = false
  config.release = ENV["RELEASE"] || ENV["GITHUB_SHA"]
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  config.before_send = lambda { |event, hint|
    if (req = event.request)
      path = (URI(req[:url]).path rescue nil)
      return nil if path == "/up" || (path && path.start_with?("/assets"))
      req[:headers]&.delete("Authorization")
      req[:headers]&.delete("Cookie")
      ua = req.dig(:headers, "User-Agent").to_s
      return nil if ua.match?(/(ELB-HealthChecker|StatusCake|UptimeRobot|Pingdom)/i)
    end

    (rand < error_sample_rate ? event : nil)
  }
end
