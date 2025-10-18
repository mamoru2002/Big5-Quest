import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AuthAPI } from '../lib/auth'
import Button from '../components/ui/Button'

const COLORS = {
  teal: '#00A8A5',
  ink:  '#2B3541',
  mint: '#CDEDEC',
  bg:   '#F9FAFB',
}

export default function Welcome() {
  const nav = useNavigate()
  const [loading, setLoading] = useState(false)

  const onGuestLogin = async () => {
    try {
      setLoading(true)
      const next = await AuthAPI.guestLogin()
      const formName = next?.form_name ?? 'guest_10'

      if (next?.result_id) {
        nav(`/diagnosis?result_id=${next.result_id}&form=${encodeURIComponent(formName)}`, { replace: true })
      } else {
        nav(`/diagnosis?form=${encodeURIComponent(formName)}`, { replace: true })
      }
    } catch (e) {
      console.error('guestLogin failed', e)
      alert('ゲストログインに失敗しました。少し時間をおいて再度お試しください。')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-dvh" style={{ background: COLORS.bg, color: COLORS.ink }}><main className="relative mx-auto w-full max-w-[390px] px-5 pb-10">
        <div className="pointer-events-none absolute inset-x-0 top-12 -z-10 flex justify-center">
          <div className="w-[152px] h-[152px] rounded-full" style={{ background: COLORS.mint }} aria-hidden />
        </div>

        <section className="pt-10 text-center">
          <h2 className="text-[28px] font-medium leading-tight">BIG5-Quest へようこそ</h2>
          <p className="mt-2 text-[16px] leading-snug">
            15週間で性格は変えられる。<br />
            心理学の理論と、あなたの性格に合わせた<br />
            一歩の積み重ねで、人生をよりよく。
          </p>
        </section>

        <section className="mt-6 flex flex-col items-center gap-3">
          <TealCard>
            <b className="font-extrabold">自分の性格を見つめ直す</b><br />
            性格診断を行い、<br />
            5つの特性から伸ばしたいものを選択。
          </TealCard>

          <ArrowDown />

          <TealCard>
            <b className="font-extrabold">あなたに合った行動クエストを実行</b><br />
            心理学に基づいた行動リストから、<br />
            週に1〜4つずつ実行。
          </TealCard>

          <ArrowDown />

          <TealCard>
            <b className="font-extrabold">変化を実感、共有する</b><br />
            毎週の変化を記録し仲間と共有、<br />
            成長の過程をグラフで確認。
          </TealCard>
        </section>

        <section className="mt-6">
          <Button
            onClick={onGuestLogin}
            disabled={loading}
            className="w-full h-[56px] bg-[#F9FAFB] text-[#2B3541] flex-col text-[15px]"
          >
            <span>{loading ? 'ログイン中…' : '試してみる（ゲストログイン）'}</span>
            <span className="text-xs font-normal mt-0.5">データは保存されません</span>
          </Button>

          <div className="mt-3 grid grid-cols-2 gap-3">
            <Button
              className="w-full h-[48px] bg-[#F9FAFB] text-[#2B3541] text-[15px]"
              onClick={() => nav('/signin')}
            >
              ログイン
            </Button>
            <Button
              className="w-full h-[48px] bg-[#F9FAFB] text-[#2B3541] text-[15px]"
              onClick={() => nav('/signup')}
            >
              新規登録
            </Button>
          </div>
        </section>
      </main>
    </div>
  )
}

function TealCard({ children }) {
  return (
    <div
      className="w-full max-w-[312px] rounded-2xl px-6 py-4 text-center text-white"
      style={{ background: COLORS.teal, boxShadow: 'inset 0 -2px 0 0 #2B3541' }}
    >
      <p className="m-0 leading-[22px] text-[15px]">{children}</p>
    </div>
  )
}

function ArrowDown() {
  return (
    <svg width="18" height="16" viewBox="0 0 18 16" className="my-1.5" aria-hidden>
      <path d="M9 16L0 6.5L1.4 5.1L8 12V0h2v12l6.6-6.9L18 6.5 9 16Z" fill={COLORS.ink} />
    </svg>
  )
}