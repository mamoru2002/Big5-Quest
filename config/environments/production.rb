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

  # credentialsは使わない。ENVで運用
  config.require_master_key = false
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")
    config.action_mailer.default_url_options = {
    host:     ENV.fetch("MAILER_HOST", "api.big5-quest.com"),
    protocol: "https"
  }

  config.action_mailer.asset_host      = ENV.fetch("MAILER_ASSET_HOST", "https://api.big5-quest.com")
  config.action_mailer.delivery_method = :ses
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = {
    from: ENV.fetch("MAIL_FROM", "no-reply@big5-quest.com")
  }
end
