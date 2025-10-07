name: Deploy API to EC2

on:
  push:
    branches: [ main ]
  workflow_dispatch:

concurrency:
  group: prod-deploy
  cancel-in-progress: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Quick SSH ping
        uses: appleboy/ssh-action@v1.2.1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_SSH_KEY }}
          port: 22
          timeout: 30s
          command_timeout: 2m
          fingerprint: ${{ secrets.DEPLOY_HOST_FINGERPRINT }}
          script: |
            set -e
            whoami
            uname -a

      - name: SSH deploy
        uses: appleboy/ssh-action@v1.2.1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_SSH_KEY }}
          port: 22
          timeout: 30s
          command_timeout: 30m
          fingerprint: ${{ secrets.DEPLOY_HOST_FINGERPRINT }}
          script: |
            set -euo pipefail
            cd /opt/Big5-Quest

            # Git 更新
            git fetch --prune
            git reset --hard origin/main

            # Bundler
            bundle config set without 'development test'
            bundle config set path 'vendor/bundle'
            bundle install --no-cache --jobs 3

            # DB マイグレーション
            sudo bash -lc '
            set -a
            source /etc/big5quest.env
            set +a
            cd /opt/Big5-Quest
            sudo --preserve-env=RAILS_ENV,SECRET_KEY_BASE,DB_HOST,DB_PORT,DB_NAME,DB_USERNAME,DB_PASSWORD,SENTRY_DSN,SENTRY_ENV \
                -u ec2-user bash -lc "RAILS_ENV=production bin/rails db:migrate"
            '

            # 再起動 & ヘルスチェック
            sudo systemctl restart big5quest
            sleep 2
            curl -fsS -H 'Host: api.big5-quest.com' -H 'X-Forwarded-Proto: https' \
              http://127.0.0.1:3000/up