import TopBar from '../../components/TopBar';
import { Link } from 'react-router-dom';

export default function VerifyNotice() {
  return (
    <div className="min-h-dvh bg-[#F9FAFB] text-[#2B3541]">
      <TopBar />
      <main className="mx-auto max-w-md px-4 py-6">
        <div className="mx-auto h-16 w-16 rounded-full bg-[#CDEDEC] grid place-items-center mb-6">
          <span className="text-[#2B3541] font-semibold">新規登録</span>
        </div>
        <div className="rounded-xl border border-[#2B3541]/20 bg-white p-4 shadow-sm">
          <p className="text-sm mb-4">
            メールをご確認ください。記載のリンクからログインできます。
          </p>
          <Link to="/" className="inline-block rounded-xl border border-[#2B3541] bg-white px-4 py-2 text-sm font-semibold shadow-sm">
            トップへ戻る
          </Link>
        </div>
      </main>
    </div>
  );
}