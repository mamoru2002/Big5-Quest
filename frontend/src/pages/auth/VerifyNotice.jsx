import React from 'react';
import { Link, useSearchParams } from 'react-router-dom';

export default function VerifyNotice() {
  const [searchParams] = useSearchParams();
  const justRegistered  = searchParams.get('registered') === '1';
  const registeredEmail = searchParams.get('email') || '';

  return (
    <div className="min-h-dvh bg-[#F9FAFB] text-[#2B3541]">
      <main className="mx-auto max-w-md px-4 py-6">
        <div className="mx-auto h-16 w-16 rounded-full bg-[#CDEDEC] grid place-items-center mb-6">
          <span className="text-[#2B3541] font-semibold">新規登録</span>
        </div>

        <div className="rounded-xl border border-[#2B3541]/20 bg-white p-4 shadow-sm">
          <p className="text-sm mb-4">
            メールをご確認ください。記載のリンクから本登録を完了できます。
          </p>

          {justRegistered && (
            <p className="mb-4 rounded-lg border border-[#2B3541]/20 bg-[#E6F7F7] px-3 py-2 text-sm text-[#1F7A7A]">
              ご登録ありがとうございます。<br />
              {registeredEmail
                ? `${registeredEmail} 宛に本登録用のメールを送信しました。`
                : '入力いただいたメールアドレス宛に本登録用のメールを送信しました。'}
              <br />メールに記載されたリンクから登録を完了してください。
            </p>
          )}

          <Link
            to="/"
            className="inline-block rounded-xl border border-[#2B3541] bg-white px-4 py-2 text-sm font-semibold shadow-sm"
          >
            トップへ戻る
          </Link>
        </div>
      </main>
    </div>
  );
}
