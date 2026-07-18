# frozen_string_literal: true

class Rack::Attack
  AUTH_PATHS = %w[
    /api/login
    /api/sign_up
    /api/auth/guest_login
    /api/auth/passwords
    /api/confirmation
  ].freeze

  throttle("auth/ip", limit: 20, period: 1.minute) do |request|
    request.ip if request.post? && AUTH_PATHS.include?(request.path)
  end

  throttle("guest-login/ip", limit: 5, period: 1.hour) do |request|
    request.ip if request.post? && request.path == "/api/auth/guest_login"
  end

  throttle("mailer/ip", limit: 5, period: 1.hour) do |request|
    mail_paths = %w[/api/auth/passwords /api/confirmation]
    request.ip if request.post? && mail_paths.include?(request.path)
  end

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    retry_after = match_data[:period].to_i
    body = { error: "rate_limited", message: "時間をおいて再度お試しください" }.to_json

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [ body ]
    ]
  end
end
