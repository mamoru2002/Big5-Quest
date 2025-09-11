Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://big5-quest.com",
            "https://www.big5-quest.com",
            "http://localhost:5173",
            "http://127.0.0.1:5173"

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[ETag X-Request-Id],
      max_age: 600
  end
end
