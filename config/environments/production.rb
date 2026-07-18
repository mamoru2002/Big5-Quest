require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # 静的ファイルのキャッシュ
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Active Storage
  config.active_storage.service = :local

  # リバプロ前提でHTTPS扱い
  config.assume_ssl = true
  config.force_ssl  = true
  # /up はHTTP→HTTPSリダイレクトを除外（ヘルスチェック用）
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # ログ
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # I18n
  config.i18n.fallbacks = true

  # DB
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # Rack::Attack のスロットリング保存先。単一Puma構成を前提とする。
  config.cache_store = :memory_store, { size: 64.megabytes }

  # credentialsは使わない。ENVで運用
  config.require_master_key = false
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")

  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {
    host:     ENV["MAILER_HOST"].presence || "api.big5-quest.com",
    protocol: ENV["MAILER_PROTOCOL"].presence || "https"
  }

  delivery_method = (ENV["MAILER_DELIVERY_METHOD"].presence || "ses_v2").to_sym
  config.action_mailer.delivery_method = delivery_method

  if delivery_method == :smtp
    require "active_model"
    boolean = ActiveModel::Type::Boolean.new

    config.action_mailer.smtp_settings = {
      address:              ENV["SMTP_ADDRESS"].presence,
      port:                 (ENV["SMTP_PORT"].presence || 587).to_i,
      domain:               ENV["SMTP_DOMAIN"].presence,
      user_name:            ENV["SMTP_USERNAME"].presence,
      password:             ENV["SMTP_PASSWORD"].presence,
      authentication:       (ENV["SMTP_AUTHENTICATION"].presence || "login").to_sym,
      enable_starttls_auto: boolean.cast(ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true"))
    }.compact
  end
end
