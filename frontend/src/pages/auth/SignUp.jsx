import React, { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import TopBar from '../../components/TopBar'
import Button from '../../components/ui/Button'
import { AuthAPI } from '../../lib/api'
import api from '../../lib/api'

const COLORS = {
  teal: '#00A8A5',
  ink:  '#2B3541',
  mint: '#CDEDEC',
  bg:   '#F9FAFB',
}

export default function SignUp() {
  const nav = useNavigate()
  const [nickname, setNickname] = useState('')
  const [email, setEmail]       = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading]   = useState(false)
  const [error, setError]       = useState('')

  const doSignUp = async ({ nickname, email, password }) => {
    if (AuthAPI && typeof AuthAPI.signUp === 'function') {
      return AuthAPI.signUp(nickname, email, password)
    }
    return api.post('/sign_up', { nickname, email, password }).then(r => r.data)
  }

  const onSubmit = async (e) => {
    e.preventDefault()
    if (loading) return
    setError('')

    try {
      setLoading(true)
      await doSignUp({ nickname: nickname.trim(), email: email.trim(), password })
      nav('/diagnosis', { replace: true })
    } catch (err) {
      console.error('signup failed', err)
      const msg =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        '登録に失敗しました。入力内容をご確認ください。'
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-dvh" style={{ background: COLORS.bg, color: COLORS.ink }}>
      <TopBar title="BIG5-Quest" rounded />

      <main className="relative mx-auto w-full max-w-[390px] px-5 pb-10">
        <div className="pointer-events-none absolute inset-x-0 top-12 -z-10 flex justify-center">
          <div className="w-[100px] h-[100px] rounded-full" style={{ background: COLORS.mint }} aria-hidden />
        </div>

        <section className="pt-8 text-center">
          <h2 className="text-[24px] font-medium leading-tight">新規登録</h2>
          <p className="mt-2 text-[16px] leading-snug">
            ニックネームとメールアドレス<br />
            とパスワードを入力してください
          </p>
        </section>

        <section
          className="mt-6 rounded-xl p-5"
          style={{ background: COLORS.bg, border: `3px solid ${COLORS.ink}` }}
        >
          <form onSubmit={onSubmit} className="space-y-5">
            <div>
              <label className="block text-[14px] mb-1">ニックネーム(必須)</label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                className="w-full h-[35px] rounded-[5px] px-3 outline-none"
                style={{ background: COLORS.mint, border: `1px solid ${COLORS.ink}`, color: COLORS.ink }}
                placeholder="ニックネームを入力"
              />
            </div>

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
                placeholder="メールアドレスを入力"
              />
            </div>

            <div>
              <label className="block text-[14px] mb-1">パスワード(必須)</label>
              <input
                type="password"
                autoComplete="new-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-[35px] rounded-[5px] px-3 outline-none"
                style={{ background: COLORS.mint, border: `1px solid ${COLORS.ink}`, color: COLORS.ink }}
                placeholder="パスワードを入力"
              />
            </div>

            {error && <p className="text-red-600 text-sm">{error}</p>}

            <Button
              type="submit"
              disabled={loading}
              className="w-full h-[52px] bg-[#F9FAFB] text-[#2B3541] text-[16px]"
            >
              {loading ? '作成中…' : 'アカウント作成'}
            </Button>

            <div className="text-[12px] text-[#2B3541]">
              ※ニックネームは自由に設定できます。<br />
              本名や個人情報は入力しないでください。<br />
              ※入力内容から個人が特定されることはありません。
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
          <div className="flex-1" />
          <Link to="/signin" className="self-center underline text-[14px]">
            すでにアカウントをお持ちの方はこちら
          </Link>
        </div>
      </main>
    </div>
  )
}