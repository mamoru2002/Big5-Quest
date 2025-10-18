import React, { useEffect, useRef } from 'react'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { getAuthToken, clearAuthToken, clearVisitToken } from '../lib/api'
import { AuthAPI } from '../lib/auth'

const COLORS = { teal: '#00A8A5', ink: '#2B3541' }

export default function AppMenu({ open, onClose }) {
  const nav = useNavigate()
  const loc = useLocation()
  const closeBtnRef = useRef(null)
  const authed = Boolean(getAuthToken())

  useEffect(() => {
    if (!open) return
    const onKey = (e) => { if (e.key === 'Escape') onClose?.() }
    window.addEventListener('keydown', onKey)
    const id = setTimeout(() => closeBtnRef.current?.focus(), 0)
    return () => { window.removeEventListener('keydown', onKey); clearTimeout(id) }
  }, [open, onClose])

  useEffect(() => { if (open) onClose?.() }, [loc.pathname])

  const handleLogout = async () => {
    try { await AuthAPI.logout() } catch (_E) { console.debug(_E) }
    try { clearAuthToken() }     catch (_E) { console.debug(_E) }
    try { clearVisitToken() }    catch (_E) { console.debug(_E) }
    onClose?.()
    nav('/signin', { replace: true })
  }

  const itemsCommon = [
    { to: '/',          label: 'ホーム' },
    { to: '/mypage',    label: 'マイページ' },
    { to: '/diagnosis', label: '性格診断をはじめる' },
    { to: '/dashboard', label: 'ダッシュボード' },
  ]
  const itemsGuest  = [
    { to: '/signin', label: 'ログイン' },
    { to: '/signup', label: '新規登録' },
  ]
  const itemsAuthed = [{ asButton: true, onClick: handleLogout, label: 'ログアウト' }]

  return (
    <>
      <div
        onClick={onClose}
        className={[
          'fixed inset-0 z-50 bg-black/40 transition-opacity duration-200 lg:hidden',
          open ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none',
        ].join(' ')}
        aria-hidden
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="appmenu-title"
        className={[
          'fixed left-0 right-0 top-0 z-[60] lg:hidden',
          'w-full max-h-[80vh] bg-white shadow-xl rounded-b-2xl',
          'transition-transform duration-200 will-change-transform',
          open ? 'translate-y-0' : '-translate-y-full',
          'flex flex-col',
        ].join(' ')}
        style={{ color: COLORS.ink }}
      >
        <div className="h-12 flex items-center justify-between px-5 rounded-b-2xl"
             style={{ background: COLORS.teal, color: '#fff' }}>
          <span id="appmenu-title" className="text-base font-bold">メニュー</span>
          <button
            ref={closeBtnRef}
            type="button"
            onClick={onClose}
            className="rounded px-2 py-1 text-white/90 focus:outline-none focus:ring focus:ring-white/40"
            aria-label="メニューを閉じる"
          >×</button>
        </div>
        <NavList
          authed={authed}
          itemsCommon={itemsCommon}
          itemsGuest={itemsGuest}
          itemsAuthed={itemsAuthed}
          onItemClick={onClose}
        />
      </div>

      <aside
        className="hidden lg:fixed lg:inset-y-0 lg:left-0 lg:z-40 lg:w-72 lg:bg-white lg:shadow-xl lg:flex lg:flex-col"
        style={{ color: COLORS.ink }}
        aria-label="サイドメニュー"
      >
        <div className="h-12 flex items-center px-5"
             style={{ background: COLORS.teal, color: '#fff' }}>
          <span className="text-base font-bold">メニュー</span>
        </div>
        <NavList
          authed={authed}
          itemsCommon={itemsCommon}
          itemsGuest={itemsGuest}
          itemsAuthed={itemsAuthed}
        />
      </aside>
    </>
  )
}

function NavList({ authed, itemsCommon, itemsGuest, itemsAuthed, onItemClick }) {
  return (
    <nav className="flex-1 overflow-y-auto p-3">
      <ul className="space-y-1">
        {itemsCommon.map(({ to, label }) => (
          <li key={to}>
            <Link
              to={to}
              onClick={onItemClick}
              className="block rounded-lg px-4 py-3 hover:bg-gray-100 active:bg-gray-200"
            >{label}</Link>
          </li>
        ))}
        {!authed && itemsGuest.map(({ to, label }) => (
          <li key={to}>
            <Link
              to={to}
              onClick={onItemClick}
              className="block rounded-lg px-4 py-3 hover:bg-gray-100 active:bg-gray-200"
            >{label}</Link>
          </li>
        ))}
        {authed && itemsAuthed.map(({ label, asButton, onClick }) => (
          <li key={label}>
            {asButton && (
              <button
                type="button"
                onClick={onClick}
                className="w-full text-left rounded-lg px-4 py-3 hover:bg-gray-100 active:bg-gray-200"
              >{label}</button>
            )}
          </li>
        ))}
      </ul>
    </nav>
  )
}