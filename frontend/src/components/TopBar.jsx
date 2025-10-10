import React, { useState } from 'react'
import AppMenu from './AppMenu'

export default function TopBar({ title = 'BIG5-Quest', rounded = true }) {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <>
      <header
        className={[
          'sticky top-0 z-10 bg-[#00A8A5] text-white',
          rounded ? 'rounded-b-2xl lg:rounded-none' : '',
          'lg:ml-72',
        ].join(' ')}
      >
        <div className="mx-auto max-w-3xl px-4 py-3 flex items-center justify-between">
          <div className="font-bold">{title}</div>

          <button
            type="button"
            onClick={() => setMenuOpen(true)}
            aria-label="メニューを開く"
            aria-haspopup="dialog"
            aria-expanded={menuOpen ? 'true' : 'false'}
            className="lg:hidden flex items-center gap-2 text-white/90 hover:text-white focus:outline-none focus:ring focus:ring-white/40 rounded px-2 py-1"
          >
            <span className="text-sm leading-none">menu</span>
            <span className="flex flex-col gap-1">
              <i className="block w-6 h-[3px] rounded bg-current" />
              <i className="block w-6 h-[3px] rounded bg-current" />
              <i className="block w-6 h-[3px] rounded bg-current" />
            </span>
          </button>
        </div>
      </header>

      <AppMenu open={menuOpen} onClose={() => setMenuOpen(false)} />
    </>
  )
}