import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import Button from '../../components/ui/Button'
import { AuthAPI } from '../../lib/auth'

const COLORS = {
  teal: '#00A8A5',
  ink:  '#2B3541',
  mint: '#CDEDEC',
  bg:   '#F9FAFB',
}

export default function ForgotPassword() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  const onSubmit = async (event) => {
    event.preventDefault()
    if (loading) return

    setError('')
    setMessage('')

    try {
      setLoading(true)
      await AuthAPI.requestPasswordReset(email.trim())
      setMessage('パスワード再設定用のメールを送信しました。数分待っても届かない場合は迷惑メールフォルダもご確認ください。')
    } catch (err) {
      console.error('password reset request failed', err)
      const msg = err?.response?.data?.error || 'メールの送信に失敗しました。時間をおいて再度お試しください。'
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-dvh" style={{ background: COLORS.bg, color: COLORS.ink }}><main className="relative mx-auto w-full max-w-[390px] px-5 pb-10">
        <div className="pointer-events-none absolute inset-x-0 top-12 -z-10 flex justify-center">
          <div className="w-[100px] h-[100px] rounded-full" style={{ background: COLORS.mint }} aria-hidden />
        </div>

        <section className="pt-8 text-center">
          <h2 className="text-[24px] font-medium leading-tight">パスワードを忘れた方へ</h2>
          <p className="mt-2 text-[16px] leading-snug">
            ご登録のメールアドレスを入力してください。<br />
            再設定用のリンクをお送りします。
          </p>
        </section>

        <section
          className="mt-6 rounded-xl p-5"
          style={{ background: COLORS.bg, border: `3px solid ${COLORS.ink}` }}
        >
          <form onSubmit={onSubmit} className="space-y-5">
            {message && (
              <p className="text-sm rounded-lg border border-[#2B3541]/20 bg-white px-3 py-2 text-[#1F7A7A]">
                {message}
              </p>
            )}

            {error && (
              <p className="text-sm text-red-600">{error}</p>
            )}

            <div>
              <label className="block text-[14px] mb-1">メールアドレス(必須)</label>
              <input
                type="email"
                inputMode="email"
                autoComplete="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full h-[35px] rounded-[5px] px-3 outline-none"
                style={{ background: COLORS.mint, border: `1px solid ${COLORS.ink}`, color: COLORS.ink }}
              />
            </div>

            <Button
              type="submit"
              disabled={loading}
              className="w-full h-[52px] bg-[#F9FAFB] text-[#2B3541] text-[16px]"
            >
              {loading ? '送信中…' : 'メールを送信する'}
            </Button>
          </form>
        </section>

        <div className="mt-6 flex flex-wrap gap-3">
          <Link to="/signin" className="flex-1 min-w-[140px] rounded-xl border border-[#2B3541] bg-white px-4 py-2 text-center text-[14px] font-semibold text-[#2B3541]">
            ログイン画面へ戻る
          </Link>
          <Link to="/" className="flex-1 min-w-[140px] rounded-xl border border-transparent bg-[#CDEDEC] px-4 py-2 text-center text-[14px] font-semibold text-[#2B3541]">
            トップへ戻る
          </Link>
        </div>
      </main>
    </div>
  )
}
