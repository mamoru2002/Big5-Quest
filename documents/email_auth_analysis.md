# メール認証機能の現状分析

## 実装概要
- `UserCredential` モデルが Devise の `:confirmable` を利用し、登録時に確認メールを送信する。Rails 側では未確認ユーザーには `202 Accepted` を返し、フロントエンドでは確認案内を表示する。【F:app/models/user_credential.rb†L1-L10】【F:app/controllers/api/auth/registrations_controller.rb†L6-L35】【F:frontend/src/pages/auth/SignUp.jsx†L21-L47】
- `/api/confirmation` の `GET` と `POST` がオーバーライドされた `ConfirmationsController` によって提供され、トークン検証後はフロントエンドへリダイレクトし、再送要求にも対応する設計となっている。【F:config/routes.rb†L4-L24】【F:app/controllers/api/auth/confirmations_controller.rb†L1-L23】

## 確認された不足・懸念点
1. **送信元アドレス設定が不一致**
   - Devise の `mailer_sender` がテンプレート値 (`please-change-me...`) のままであり、`ApplicationMailer` の `default from` と噛み合っていない。通知メールの `From` が意図しないドメインになる可能性がある。【F:config/initializers/devise.rb†L3-L55】【F:app/mailers/application_mailer.rb†L1-L4】

2. **本番環境のメール送信設定が不足**
   - `production.rb` では `default_url_options` のみで SMTP などの配送設定がされておらず、環境変数による `delivery_method`/`smtp_settings` の指定がないため本番でメールが送信されない。開発環境でも送信手段が未設定のため検証が難しい。【F:config/environments/production.rb†L20-L40】【F:config/environments/development.rb†L20-L70】

3. **確認メール再送のUI欠如**
   - API には `POST /api/confirmation` が用意されているが、フロントエンドの `/verify` 画面は文言表示のみで再送フォームがないため、ユーザーが自己解決できない。未確認状態でのログインも単一のエラーメッセージのみで誘導がない。【F:frontend/src/pages/auth/VerifyNotice.jsx†L1-L20】【F:frontend/src/pages/auth/SignIn.jsx†L1-L124】

4. **未確認ユーザーのガイダンス不足**
   - ログイン失敗時は常に「メールアドレスまたはパスワードが正しくありません」と表示され、未確認ユーザー向けの案内がない。サーバー側でも `resend_confirmation_instructions` を促すレスポンスが用意されていないため、UX が低下する恐れがある。【F:app/controllers/api/auth/sessions_controller.rb†L1-L32】【F:frontend/src/pages/auth/SignIn.jsx†L20-L107】

## 補強の方向性
- Devise 初期設定を `no-reply@big5-quest.com` など実際のドメインに合わせ、環境別に Action Mailer の配送手段を明確化する（SMTP・API ベース等）。
- `/verify` 画面に確認メール再送のフォームとステータス表示を追加し、API の `POST /api/confirmation` と連携させる。
- ログイン API とフロントに未確認ユーザーのケース分岐を加え、再送案内とリンクを提示する。
- 開発環境では `letter_opener_web` などの導入を検討し、メールフローの検証を容易にする。
