import React, { useMemo, useState, useEffect } from 'react'
import { useNavigate, Link, useLocation } from 'react-router-dom'
import Button from '../../components/ui/Button'
import { AuthAPI } from '../../lib/auth'

const COLORS = {
  teal: '#00A8A5',
  ink:  '#2B3541',
  mint: '#CDEDEC',
  bg:   '#F9FAFB',
}

export default function SignIn() {
  const nav = useNavigate()
  const location = useLocation()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [info, setInfo] = useState('')
  const [showResendPrompt, setShowResendPrompt] = useState(false)

  const confirmedMessage = useMemo(() => {
    const params = new URLSearchParams(location.search)
    return params.get('confirmed') === '1'
      ? 'メールアドレスの確認が完了しました。ログインしてください。'
      : ''
  }, [location.search])

  useEffect(() => {
    if (confirmedMessage) {
      setInfo(confirmedMessage)
    }
  }, [confirmedMessage])

  const onSubmit = async (e) => {
    e.preventDefault()
    if (loading) return
    setError('')
    setInfo('')
    setShowResendPrompt(false)
    try {
      setLoading(true)
      const trimmedEmail = email.trim()
      await AuthAPI.login(trimmedEmail, password)
      nav('/diagnosis', { replace: true })
    } catch (err) {
      console.error('login failed', err)
      const status = err?.response?.status
      const data = err?.response?.data

      if (status === 403 && data?.error === 'unconfirmed') {
        setError(data?.message || 'メール認証が完了していません。受信トレイをご確認ください。')
        setShowResendPrompt(true)
      } else if (data?.message) {
        setError(data.message)
      } else {
        setError('メールアドレスまたはパスワードが正しくありません。')
      }
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
          <h2 className="text-[24px] font-medium leading-tight">ログイン</h2>
          <p className="mt-2 text-[16px] leading-snug">
            メールアドレスとパスワード<br />を入力してください
          </p>
        </section>

        <section
          className="mt-6 rounded-xl p-5"
          style={{
            background: COLORS.bg,
            border: `3px solid ${COLORS.ink}`,
          }}
        >
          <form onSubmit={onSubmit} className="space-y-5">
            {info && (
              <p className="text-sm rounded-lg border border-[#2B3541]/20 bg-white px-3 py-2 text-[#1F7A7A]">
                {info}
              </p>
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
                style={{
                  background: COLORS.mint,
                  border: `1px solid ${COLORS.ink}`,
                  color: COLORS.ink,
                }}
              />
            </div>

            <div>
              <label className="block text-[14px] mb-1">パスワード(必須)</label>
              <input
                type="password"
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-[35px] rounded-[5px] px-3 outline-none"
                style={{
                  background: COLORS.mint,
                  border: `1px solid ${COLORS.ink}`,
                  color: COLORS.ink,
                }}
              />
            </div>

            {error && (
              <p className="text-red-600 text-sm">{error}</p>
            )}

            {showResendPrompt && (
              <div className="rounded-lg border border-[#2B3541]/20 bg-[#E6F7F7] p-3 text-sm text-[#2B3541]">
                <p className="mb-2">確認メールを再送するには以下からお手続きください。</p>
                <Link
                  to={`/verify?email=${encodeURIComponent(email.trim())}`}
                  className="font-semibold underline"
                >
                  確認メールの再送画面へ
                </Link>
              </div>
            )}

            <Button
              type="submit"
              disabled={loading}
              className="w-full h-[52px] bg-[#F9FAFB] text-[#2B3541] text-[16px]"
            >
              {loading ? 'ログイン中…' : 'ログイン'}
            </Button>

            <div className="text-center">
              <Link to="/forgot" className="underline text-[16px]">
                パスワードを忘れた方はこちら
              </Link>
            </div>
          </form>
        </section>
        
        <div className="mt-6 flex">
          <Button
            type="button"
            onClick={() => nav(-1)}
            className="h-[35px] px-4 py-2 text-[16px] bg-[#F9FAFB] text-[#2B3541]"
          >
            戻る
          </Button>
        </div>
      </main>
    </div>
  )
}