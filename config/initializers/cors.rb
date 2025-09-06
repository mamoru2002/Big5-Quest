require "rack/cors"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://big5-quest.com", "https://www.big5-quest.com"

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: %w[ETag],
      max_age: 7200

    resource "/up",
      headers: :any,
      methods: %i[get options head],
      credentials: false
  end
end
