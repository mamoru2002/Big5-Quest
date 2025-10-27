import React, { useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { AuthAPI } from '../../lib/auth';

export default function VerifyNotice() {
  const [searchParams] = useSearchParams();
  const initialEmail = searchParams.get('email') ?? '';
  const initialError = searchParams.get('error') ?? '';
  const justRegistered = searchParams.get('registered') === '1';
  const initialNotice = justRegistered
    ? 'ご登録ありがとうございます。入力いただいたメールアドレス宛に本登録用のメールを送信しました。メールに記載されたリンクから登録を完了してください。'
    : '';
  const [email, setEmail] = useState(initialEmail);
  const [submitting, setSubmitting] = useState(false);
  const [notice, setNotice] = useState(initialNotice);
  const [error, setError] = useState(initialError);

  const onSubmit = async (event) => {
    event.preventDefault();
    if (submitting) return;
    setNotice('');
    setError('');

    try {
      setSubmitting(true);
      await AuthAPI.resendConfirmation(email.trim());
      setNotice('確認メールを再送しました。数分待っても届かない場合は迷惑メールフォルダもご確認ください。');
    } catch (err) {
      console.error('resend confirmation failed', err);
      setError('確認メールの再送に失敗しました。時間をおいて再度お試しください。');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-dvh bg-[#F9FAFB] text-[#2B3541]"><main className="mx-auto max-w-md px-4 py-6">
        <div className="mx-auto h-16 w-16 rounded-full bg-[#CDEDEC] grid place-items-center mb-6">
          <span className="text-[#2B3541] font-semibold">新規登録</span>
        </div>
        <div className="rounded-xl border border-[#2B3541]/20 bg-white p-4 shadow-sm">
          <p className="text-sm mb-4">
            メールをご確認ください。記載のリンクからログインできます。
          </p>

          {notice && (
            <p className="mb-4 rounded-lg border border-[#2B3541]/20 bg-[#E6F7F7] px-3 py-2 text-sm text-[#1F7A7A]">
              {notice}
            </p>
          )}

          {error && (
            <p className="mb-4 rounded-lg border border-red-400/60 bg-red-50 px-3 py-2 text-sm text-red-700">
              {error}
            </p>
          )}

          <form className="space-y-4" onSubmit={onSubmit}>
            <div>
              <label className="block text-xs font-semibold text-[#2B3541]/70 mb-1">登録メールアドレス</label>
              <input
                type="email"
                required
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                className="w-full rounded-lg border border-[#2B3541]/30 bg-[#F9FAFB] px-3 py-2 text-sm outline-none focus:border-[#2B3541]"
              />
            </div>
            <button
              type="submit"
              disabled={submitting}
              className="w-full rounded-xl border border-[#2B3541] bg-[#2B3541] px-4 py-2 text-sm font-semibold text-white transition hover:bg-[#1F2A35] disabled:cursor-not-allowed disabled:opacity-70"
            >
              {submitting ? '再送中…' : '確認メールを再送する'}
            </button>
          </form>

          <div className="mt-6 space-y-2 text-xs text-[#2B3541]/70">
            <p>・迷惑メールフォルダやプロモーションタブに振り分けられていないかご確認ください。</p>
            <p>・それでも届かない場合は、受信許可設定を行ってから再度お試しください。</p>
          </div>

          <div className="mt-6 flex flex-wrap gap-2">
            <Link to="/" className="inline-flex flex-1 min-w-[140px] justify-center rounded-xl border border-[#2B3541] bg-white px-4 py-2 text-sm font-semibold shadow-sm">
              トップへ戻る
            </Link>
            <Link to="/signin" className="inline-flex flex-1 min-w-[140px] justify-center rounded-xl border border-transparent bg-[#CDEDEC] px-4 py-2 text-sm font-semibold text-[#2B3541]">
              ログイン画面へ
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}