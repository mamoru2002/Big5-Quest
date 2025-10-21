# Big5-Quest

## 概要
Big5（N/E/O/A/C）の各特性に対して、診断と「週間チャレンジ」を組み合わせて継続改善を目指すアプリです。初期診断（W0）で基準値を取り、以降はユーザーが選んだフォーカス特性を中心に週次で軽量な再診断と実践（チャレンジ）を繰り返します。

## オリジナルプロダクトの URL
- フロント: https://big5-quest.com/
- API: https://api.big5-quest.com/

---

## 使用技術
- フロントエンド: React + Vite, Chart.js
- バックエンド: Ruby on Rails 8, Puma
- データベース: MySQL (本番は RDS)
- 認証: トークンベース（ゲストログインを提供）
- 監視/トレース（任意）: Sentry（環境変数で有効化）
- デプロイ: systemd + Puma（EC2）

---


## 機能一覧
- ゲストログイン（ワンクリックで体験開始）
- 性格診断
  - W0（初回）: 50問（全特性）
  - 週次: 10問（フォーカス特性。A/B/C バケット回転 + アンカー2）
  - 4週ごと: 26問（フォーカス10 + 他特性×各4）
  - W15（最終）: 50問（全特性）
- チャレンジ選択（1〜4件/週）
- マイページ
  - 累計統計（達成数/実行数/達成期間）
  - 特性差分グラフ（W0基準の週次変化）
  - 来週スキップ（トグルで予約/解除）
  - プロフィール編集（名前/自己紹介）

---

## 主要 API（抜粋）
- 認証
  - `POST /api/auth/guest_login` … ゲストトークン発行
  - `GET  /api/me` … 現在のユーザー情報

- 診断/フォーム
  - `POST /api/diagnosis_results` … 診断開始（result_id 発行）
  - `PUT  /api/diagnosis_results/:id/responses` … 回答送信
  - `POST /api/diagnosis_results/:id/complete` … 診断完了（スコア算出）
  - `GET  /api/diagnosis_forms/:name/questions` … 設問取得

- チャレンジ
  - `GET  /api/traits/:code/challenges` … 特性別チャレンジ一覧
  - `POST /api/user_challenges` … 週のチャレンジ確定
  - `PATCH /api/user_challenges/:id` … 進捗更新

- 統計/マイページ
  - `GET  /api/stats/summary` … 累計サマリー
  - `GET  /api/stats/trait_history?code=C` … 特性差分履歴
  - `GET  /api/week_skips/status` … 来週スキップの状態
  - `PATCH /api/week_skips` … 来週スキップ更新（`{ skip: true|false }`）
  - `GET  /api/profile` / `PUT /api/profile` … プロフィール取得/更新

---

## ローカル開発（手順）

### 1) バックエンド（Rails）
```bash
# 依存インストール
bundle install

# DB 作成・マイグレーション・シード（必要に応じて）
bin/rails db:setup          # または: db:create db:migrate db:seed

# API サーバ起動（:3000）
bin/rails s -p 3000
```

### 2) フロントエンド（React/Vite）
```bash
npm --prefix frontend install
npm --prefix frontend run dev  # http://localhost:5173
```

### 3) ゲストトークンで API を叩く例
```bash
export BASE="http://localhost:3000"
export TOKEN="$(curl -sS -X POST "$BASE/api/auth/guest_login" | jq -r '.token')"
export AUTH="Authorization: Bearer $TOKEN"

curl -sS -H "$AUTH" "$BASE/api/stats/summary" | jq .
curl -sS -H "$AUTH" "$BASE/api/week_skips/status" | jq .
curl -sS -X PATCH -H "$AUTH" -H "Content-Type: application/json"   -d '{"skip":true}' "$BASE/api/week_skips" | jq .
```

### 4) RSpec
```bash
bin/rails db:test:prepare
bundle exec rspec
```

---

## デプロイ（概略）
- **Puma + systemd** で常駐。`/etc/big5quest.env` などの EnvironmentFile から `SECRET_KEY_BASE`・DB 接続情報・SENTRY_DSN を読み込む想定。
- 逆プロキシがある場合は **Nginx/ALB** で `proxy_pass` → Puma（127.0.0.1:3000）
- データベースは **MySQL (RDS)**。マイグレーション適用後に起動。

### 例: Nginx（API 側最小構成）
```nginx
server {
  listen 443 ssl http2;
  server_name api.big5-quest.com;

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://127.0.0.1:3000;
  }
}
```

---

## 補足メモ
- `weekly_pauses.weekly_progress_id` に **UNIQUE** 制約を付け、1つの週に対してスキップ予約が **重複登録されない** ようにしています（アプリ側トグルは冪等）。
- `focus_trait_code` はフロントで `localStorage` に保存し、マイページで該当特性の差分履歴を表示します。
- 診断フォームの問題セットは `db/seeds/forms_map.json` を参照し、W0/週次/26問などのローテーションルールで出題します。
