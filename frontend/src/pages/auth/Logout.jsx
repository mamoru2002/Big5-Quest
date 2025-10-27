import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { AuthAPI } from '../../lib/auth'
import { clearAuthToken, clearVisitToken, clearGuestSession } from '../../lib/api'

export default function Logout() {
  const nav = useNavigate()

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      await AuthAPI.logout().catch(() => undefined)

      clearAuthToken()
      clearVisitToken()
      clearGuestSession()

      if (!cancelled) nav('/signin', { replace: true })
    })()
    return () => { cancelled = true }
  }, [nav])

  return (
    <div className="min-h-dvh flex items-center justify-center">
      <div className="text-slate-600">ログアウト中…</div>
    </div>
  )
}