import React, { useState, useEffect } from 'react'
import Layout from '../components/Layout'
import Button from '../components/ui/Button'
import { fetchCurrentWeek, updateUserChallenge } from '../api'

export default function Dashboard() {
  const [week, setWeek]   = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    ;(async () => {
      try {
        const data = await fetchCurrentWeek()
        setWeek(data)
      } catch (e) {
        console.error(e)
        setError('今週のデータ取得に失敗しました')
      } finally {
        setLoading(false)
      }
    })()
  }, [])

  if (loading) return <p className="text-center p-4">読み込み中…</p>
  if (error)   return <p className="text-center p-4 text-red-600">{error}</p>
  if (!week)   return null

  const challenges = week.challenges || []
  const completed  = challenges.filter(c => c.status === 'expired')
  const active     = challenges.filter(c => c.status !== 'expired')

  const totalSlots = Math.min(4, challenges.length)
  const doneCount  = completed.length
  const doneSlots  = Math.min(doneCount, totalSlots)

  const patchLocal = (id, attrs) => {
    setWeek(prev => ({
      ...prev,
      challenges: prev.challenges.map(uc =>
        uc.id === id ? { ...uc, ...attrs } : uc
      )
    }))
  }

  async function markDone(uc) {
    if (!week.editable) return
    const next = { status: 'expired', exec_count: Math.max(1, uc.exec_count || 0) }
    patchLocal(uc.id, next)
    try {
      await updateUserChallenge(uc.id, next)
    } catch (e) {
      console.error(e)
      patchLocal(uc.id, { status: uc.status, exec_count: uc.exec_count })
      console.error('updateUserChallenge failed:', {
   status: e.response?.status,
   data:   e.response?.data,
   sent:   e.config?.data,
 })
 alert('更新に失敗しました')
    }
  }

  async function inc(uc) {
    if (!week.editable) return
    const next = { exec_count: (uc.exec_count || 0) + 1 }
    patchLocal(uc.id, next)
    try {
      await updateUserChallenge(uc.id, next)
    } catch (e) {
      console.error(e)
      patchLocal(uc.id, { exec_count: uc.exec_count })
      alert('更新に失敗しました')
    }
  }
  async function dec(uc) {
    if (!week.editable) return
    const nextVal = Math.max(0, (uc.exec_count || 0) - 1)
    const next = { exec_count: nextVal }
    patchLocal(uc.id, next)
    try {
      await updateUserChallenge(uc.id, next)
    } catch (e) {
      console.error(e)
      patchLocal(uc.id, { exec_count: uc.exec_count })
      alert('更新に失敗しました')
    }
  }

  return (
    <Layout>
      <h1 className="text-2xl font-bold text-center">
        チャレンジ{week.week_no}週目
      </h1>

      <div className="mt-4 text-center">
        <p className="font-semibold">今週のチャレンジ：{doneCount}/4 完了！</p>
        <div className="flex justify-center gap-4 mt-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <div
              key={i}
              className={
                i < doneSlots
                  ? 'w-10 h-10 rounded-full bg-[#00A8A5] flex items-center justify-center text-[#F9FAFB] text-2xl'
                  : 'w-10 h-10 rounded-full border-2 border-[#2B3541]'
              }
            >
              {i < doneSlots ? '✓' : ''}
            </div>
          ))}
        </div>
      </div>

      <section className="mt-6 rounded-xl bg-[#CDEDEC] p-4">
        <div className="flex items-center justify-between">
          <h2 className="font-bold">完了したチャレンジ</h2>
          <span className="text-sm text-gray-700">回数</span>
        </div>

        {completed.length === 0 ? (
          <p className="mt-3 text-sm text-gray-600">まだ完了したチャレンジはありません。</p>
        ) : (
          <ul className="mt-3 space-y-3">
            {completed.map(uc => (
              <li key={uc.id} className="flex items-center gap-2">
                <button
                  onClick={() => dec(uc)}
                  disabled={!week.editable}
                  aria-label="回数を減らす"
                  className="w-9 h-9 rounded-full border-2 border-[#2B3541] bg-white
                             flex items-center justify-center text-xl
                             disabled:opacity-50"
                >
                  –
                </button>

                <div className="flex-1">
                  <div className="rounded-full bg-[#00A8A5] text-[#F9FAFB] px-4 py-2 text-sm">
                    {uc.challenge.title}
                  </div>
                </div>

                <button
                  onClick={() => inc(uc)}
                  disabled={!week.editable}
                  aria-label="回数を増やす"
                  className="w-9 h-9 rounded-full border-2 border-[#2B3541] bg-white
                             flex items-center justify-center text-xl
                             disabled:opacity-50"
                >
                  +
                </button>

                <div className="w-9 h-9 rounded-full border-2 border-[#2B3541] bg-white
                                flex items-center justify-center text-sm font-semibold">
                  {uc.exec_count ?? 0}
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="mt-6">
        <h2 className="text-center font-bold mb-3">挑戦中のチャレンジ</h2>

        {active.length === 0 ? (
          <p className="text-center text-sm text-gray-600">挑戦中のチャレンジはありません。</p>
        ) : (
          <div className="space-y-3">
            {active.map(uc => (
              <Button
                key={uc.id}
                onClick={() => markDone(uc)}
                disabled={!week.editable}
                className="w-full bg-[#00A8A5] text-[#F9FAFB]"
              >
                {uc.challenge.title}
              </Button>
            ))}
          </div>
        )}
      </section>

    </Layout>
  )
}