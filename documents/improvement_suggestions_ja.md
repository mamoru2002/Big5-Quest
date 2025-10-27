# 改善提案メモ

## 1. 診断結果作成 API のパラメータ整合性
- `frontend/src/lib/api.ts` の `DiagnosisAPI.createResult` は `diagnosis_form_id` を POST していますが、サーバー側の `Api::DiagnosisResultsController#create` は `form_name` を受け取る前提になっています。
- 実際のフォーム起動 (`frontend/src/pages/DiagnosisForm.jsx`) では `startDiagnosis`（`diagnosis_result: { form_name }` を送る実装）を呼び出しているため現状は動作しますが、`DiagnosisAPI` を用いた新規実装が入ると 422 エラーが発生する恐れがあります。
- `DiagnosisAPI.createResult` のパラメータ名を `form_name` に変更し、`startDiagnosis` と共通化することで API 仕様の齟齬を無くせます。

## 2. ユーザーチャレンジのコメント削除機能
- `app/services/user_challenges/update.rb` ではコメント文字列が空白の場合に既存コメントを削除せず、そのまま残ります。
- UI でコメントを空文字に更新しても削除されないため、ユーザーが誤って残したメモを消せない状態になります。
- `body.present?` が偽のときに `user_challenge.user_challenge_comment&.destroy` するなど、空白入力でコメントを削除できるようにすると UX が向上します。

## 3. 診断フォーム回答送信時のリトライ導線
- `frontend/src/pages/DiagnosisForm.jsx` の `handleSelect` 内では回答送信 (`submitAnswers`) の失敗時に `console.error` だけで UI には通知されません。
- 通信断などで回答の保存が失敗するとユーザーはエラーに気付かず、完了時に結果へ進めなくなるリスクがあります。
- 失敗時にトーストやダイアログで通知し再送信できるようにする、もしくは `submitAnswers` を `await` してエラー時にページ遷移を止めるなど、エラーハンドリングを強化する余地があります。
