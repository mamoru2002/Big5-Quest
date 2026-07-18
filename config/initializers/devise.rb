# frozen_string_literal: true

Devise.setup do |config|
  # メール送信者
  config.mailer_sender = ENV["MAILER_SENDER"].presence || ENV["MAIL_FROM"].presence || "no-reply@big5-quest.com"

  # ORM
  require "devise/orm/active_record"

  # 認証キー前処理
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  # セッション保存スキップ（API向け）
  config.skip_session_storage = [ :http_auth, :jwt ]

  # パスワードハッシュコスト
  config.stretches = Rails.env.test? ? 1 : 12

  # 退会/エラー系
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true

  # バリデーション
  config.password_length = 10..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.paranoid = true

  # サインアウト
  config.sign_out_via = :delete

  # Turbo 対応
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # APIでリダイレクトを避ける
  config.navigational_formats = []

  # ★ Devise 自身の秘密鍵はアプリの secret_key_base を使う
  config.secret_key = Rails.application.secret_key_base

  # ★ JWT も同じ鍵を使用
  config.jwt do |jwt|
    jwt.secret = Rails.application.secret_key_base
    jwt.dispatch_requests = [
      [ "POST", %r{^/api/login$} ],
      [ "POST", %r{^/api/sign_up$} ],
      [ "POST", %r{^/api/auth/guest_login$} ]
    ]
    jwt.revocation_requests = [
      [ "DELETE", %r{^/api/logout$} ]
    ]
    jwt.expiration_time = 1.day.to_i
    jwt.request_formats = { api_user_credential: [ :json ] }
  end
end
