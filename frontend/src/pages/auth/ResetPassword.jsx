import React, { useMemo, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import Button from '../../components/ui/Button'
import { AuthAPI } from '../../lib/auth'

const COLORS = {
  teal: '#00A8A5',
  ink:  '#2B3541',
  mint: '#CDEDEC',
  bg:   '#F9FAFB',
}

export default function ResetPassword() {
  const [searchParams] = useSearchParams()
  const nav = useNavigate()
  const token = useMemo(() => {
    return searchParams.get('token') || searchParams.get('reset_password_token') || ''
  }, [searchParams])

  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [completed, setCompleted] = useState(false)

  const onSubmit = async (event) => {
    event.preventDefault()
    if (loading || completed) return

    setError('')
    setMessage('')

    if (!token) {
      setError('無効なリンクです。もう一度メール送信からやり直してください。')
      return
    }

    if (password !== passwordConfirmation) {
      setError('パスワードが一致しません。再度入力してください。')
      return
    }

    try {
      setLoading(true)
      await AuthAPI.resetPassword(token, password)
      setCompleted(true)
      setMessage('パスワードを更新しました。新しいパスワードでログインしてください。')
      setPassword('')
      setPasswordConfirmation('')
    } catch (err) {
      console.error('password reset failed', err)
      const msg = err?.response?.data?.error || 'パスワードの再設定に失敗しました。リンクの有効期限が切れていないかご確認ください。'
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  const handleGoSignIn = () => {
    nav('/signin', { replace: true })
  }

  return (
    <div className="min-h-dvh" style={{ background: COLORS.bg, color: COLORS.ink }}><main className="relative mx-auto w-full max-w-[390px] px-5 pb-10">
        <div className="pointer-events-none absolute inset-x-0 top-12 -z-10 flex justify-center">
          <div className="w-[100px] h-[100px] rounded-full" style={{ background: COLORS.mint }} aria-hidden />
        </div>

        <section className="pt-8 text-center">
          <h2 className="text-[24px] font-medium leading-tight">パスワード再設定</h2>
          <p className="mt-2 text-[16px] leading-snug">
            新しいパスワードを入力してください。
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
              <label className="block text-[14px] mb-1">新しいパスワード</label>
              <input
                type="password"
                autoComplete="new-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-[35px] rounded-[5px] px-3 outline-none"
                style={{ background: COLORS.mint, border: `1px solid ${COLORS.ink}`, color: COLORS.ink }}
                disabled={completed}
              />
            </div>

            <div>
              <label className="block text-[14px] mb-1">新しいパスワード（確認）</label>
              <input
                type="password"
                autoComplete="new-password"
                required
                value={passwordConfirmation}
                onChange={(e) => setPasswordConfirmation(e.target.value)}
                className="w-full h-[35px] rounded-[5px] px-3 outline-none"
                style={{ background: COLORS.mint, border: `1px solid ${COLORS.ink}`, color: COLORS.ink }}
                disabled={completed}
              />
            </div>

            <Button
              type="submit"
              disabled={loading || completed}
              className="w-full h-[52px] bg-[#F9FAFB] text-[#2B3541] text-[16px]"
            >
              {completed ? '再設定が完了しました' : loading ? '更新中…' : 'パスワードを更新する'}
            </Button>
          </form>
        </section>

        <div className="mt-6 flex flex-wrap gap-3">
          <button
            type="button"
            onClick={handleGoSignIn}
            className="flex-1 min-w-[140px] rounded-xl border border-[#2B3541] bg-white px-4 py-2 text-[14px] font-semibold text-[#2B3541]"
          >
            ログイン画面へ
          </button>
          <Link to="/forgot" className="flex-1 min-w-[140px] rounded-xl border border-transparent bg-[#CDEDEC] px-4 py-2 text-center text-[14px] font-semibold text-[#2B3541]">
            メールを再送する
          </Link>
        </div>

        {!token && (
          <p className="mt-4 text-center text-[12px] text-red-600">
            リンクが無効です。再度メール送信からやり直してください。
          </p>
        )}
      </main>
    </div>
  )
}
