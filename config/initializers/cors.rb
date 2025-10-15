Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %r{\Ahttps?://(www\.)?big5-quest\.com\z},
            %r{\Ahttps?://app\.big5-quest\.com\z},
            "http://localhost:5173", "http://127.0.0.1:5173"

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization ETag X-Request-Id],
      max_age: 86400
  end
end
