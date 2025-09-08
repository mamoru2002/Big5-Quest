# frozen_string_literal: true

require "uri"

Sentry.init do |config|
  # --- 基本 ---
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["SENTRY_ENV"] || Rails.env
  config.enabled_environments = %w[production]

  config.release = ENV["RELEASE"] || ENV["GITHUB_SHA"]
  config.send_default_pii = false
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # --- パフォーマンスは無料枠節約のためデフォルト0 ---
  config.traces_sample_rate   = (ENV["SENTRY_TRACES_RATE"]   || "0").to_f
  config.profiles_sample_rate = (ENV["SENTRY_PROFILES_RATE"] || "0").to_f

  # --- エラーイベントのサンプリング（1.0=100%）---
  error_sample_rate = (ENV["SENTRY_ERROR_SAMPLE_RATE"] || "0.25").to_f

  # --- 送信前フィルタ ---
  # 目的：
  #  1) /up と /assets 配下は捨てる（ヘルスチェック/静的）
  #  2) /api/* 以外のリクエストは捨てる（ボット404を根こそぎカット）
  #  3) 認証系ヘッダは送らない
  #  4) 代表的な監視/クローラUAは捨てる
  #  5) runner 等の「リクエスト無しイベント」はそのまま通す
  config.before_send = lambda { |event, _hint|
    if (req = event.request)
      headers = (req[:headers] ||= {})
      headers.delete("Authorization")
      headers.delete("Cookie")

      path =
        begin
          URI(req[:url].to_s).path
        rescue
          nil
        end

      return nil if path == "/up" || path&.start_with?("/assets")

      # ボット/監視ツールの代表例
      ua = headers["User-Agent"].to_s
      return nil if ua.match?(/(ELB-HealthChecker|StatusCake|UptimeRobot|Pingdom|python-requests|curl|wget|Go-http-client)/i)

      # API 経由以外は送らない（/api/* だけ通す）
      return nil unless path&.start_with?("/api/")
    end

    # サンプリング
    rand < error_sample_rate ? event : nil
  }

  # 例外の原因チェーンにも除外設定を適用（将来 excluded_exceptions を使う場合に有効）
  config.inspect_exception_causes_for_exclusion = true
end
