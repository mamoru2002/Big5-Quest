import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import Layout from '../components/Layout'
import Button from '../components/ui/Button'
import {
  fetchCurrentWeek,
  fetchWeekSkipStatus,
  fetchMe,
  updateUserChallenge,
} from '../api'
import CompleteModal from '../components/CompleteModal'
import RedirectInfoModal from '../components/RedirectInfoModal'
import {
  buildWeekKey,
  computeNextWeekKey,
  hasRedirectedForWeek,
  isWeekScheduledToSkip,
  markRedirectedForWeek,
  markScheduledSkip,
} from '../lib/weekRedirect'

export default function Dashboard() {
  const navigate = useNavigate()
  const [week, setWeek]   = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [modalUC, setModalUC] = useState(null)

  const [userId, setUserId] = useState(null)
  const [userReady, setUserReady] = useState(false)

  const [skipStatus, setSkipStatus] = useState(null)
  const [skipReady, setSkipReady] = useState(false)
  const [skipFailed, setSkipFailed] = useState(false)

  const [diagnosisStatus, setDiagnosisStatus] = useState('unknown')
  const [diagnosisReady, setDiagnosisReady] = useState(false)

  const [autoHandled, setAutoHandled] = useState(false)
  const [redirectModal, setRedirectModal] = useState({
    open: false,
    mode: 'diagnosis',
    target: null,
    weekKey: null,
  })

  useEffect(() => {
    let active = true
    ;(async () => {
      try {
        const data = await fetchCurrentWeek()
        if (!active) return
        setWeek(data)
      } catch (e) {
        console.error('fetchCurrentWeek failed', e)
        if (!active) return
        setError('今週のデータ取得に失敗しました')
      } finally {
        if (active) setLoading(false)
      }
    })()
    return () => { active = false }
  }, [])

  useEffect(() => {
    let active = true
    ;(async () => {
      try {
        const status = await fetchWeekSkipStatus()
        if (!active) return
        setSkipStatus(status || null)
        setSkipFailed(false)
      } catch (e) {
        console.error('fetchWeekSkipStatus failed', e)
        if (!active) return
        setSkipStatus(null)
        setSkipFailed(true)
      } finally {
        if (active) setSkipReady(true)
      }
    })()
    return () => { active = false }
  }, [])

  useEffect(() => {
    let active = true
    ;(async () => {
      try {
        const me = await fetchMe()
        if (!active) return
        setUserId(me?.id ?? null)
      } catch (e) {
        console.error('fetchMe failed', e)
        if (!active) return
        setUserId(null)
      } finally {
        if (active) setUserReady(true)
      }
    })()
    return () => { active = false }
  }, [])

  useEffect(() => {
    if (!week) return

    const challengeCount = Array.isArray(week.challenges) ? week.challenges.length : 0
    const statusFromWeek = typeof week.diagnosis_status === 'string' ? week.diagnosis_status : null
    const completed = Boolean(week.diagnosis_completed)
    const hasResult = Boolean(week.result_id)

    if (statusFromWeek === 'complete' || completed || challengeCount > 0) {
      setDiagnosisStatus('complete')
    } else if (statusFromWeek === 'incomplete') {
      setDiagnosisStatus('incomplete')
    } else if (!hasResult) {
      setDiagnosisStatus('incomplete')
    } else {
      setDiagnosisStatus('unknown')
    }
    setDiagnosisReady(true)
  }, [week])

  useEffect(() => {
    if (!week || !userId || !skipReady) return
    const nextKey = computeNextWeekKey(week.start_at)
    if (!nextKey) return
    const shouldPause = Boolean(skipStatus?.next_week_paused)
    markScheduledSkip(userId, nextKey, shouldPause)
  }, [week, skipStatus, skipReady, userId])

  useEffect(() => {
    if (autoHandled) return
    if (!week || !userReady || !skipReady || !diagnosisReady) return

    if (skipFailed) {
      console.info('skip status unavailable; auto-redirect skipped')
      setAutoHandled(true)
      return
    }

    if (!userId) {
      console.info('user id unavailable; auto-redirect skipped')
      setAutoHandled(true)
      return
    }

    const weekKey = buildWeekKey(week.start_at)
    if (!weekKey) {
      console.info('week key unavailable; auto-redirect skipped')
      setAutoHandled(true)
      return
    }

    const pausedFromWeek = typeof week.paused === 'boolean' ? week.paused : null
    const isPaused = pausedFromWeek ?? isWeekScheduledToSkip(userId, weekKey)
    const alreadyRedirected = hasRedirectedForWeek(userId, weekKey)

    if (isPaused) {
      if (!alreadyRedirected) {
        setRedirectModal({ open: true, mode: 'rest', target: '/rest', weekKey })
      } else {
        navigate('/rest', { replace: true })
      }
      setAutoHandled(true)
      return
    }

    if (!alreadyRedirected) {
      setRedirectModal({ open: true, mode: 'diagnosis', target: '/diagnosis', weekKey })
      setAutoHandled(true)
      return
    }

    if (diagnosisStatus === 'incomplete') {
      navigate('/diagnosis', { replace: true })
    }

    setAutoHandled(true)
  }, [autoHandled, week, userReady, skipReady, diagnosisReady, skipFailed, userId, navigate, diagnosisStatus])

  const handleRedirectConfirm = () => {
    if (!redirectModal.open) return
    if (redirectModal.weekKey) {
      markRedirectedForWeek(userId, redirectModal.weekKey)
    }
    const target = redirectModal.target
    setRedirectModal(prev => ({ ...prev, open: false }))
    if (target) {
      navigate(target, { replace: true })
    }
  }

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

  const handleSaved = (id, fields) => {
    patchLocal(id, fields)
  }

  return (
    <Layout>
      <RedirectInfoModal
        open={redirectModal.open}
        mode={redirectModal.mode}
        onConfirm={handleRedirectConfirm}
      />

      <h1 className="text-2xl font-bold text-center">
        チャレンジ{week.week_no}週目
      </h1>

      <div className="mt-4 text-center">
        <p className="font-semibold">今週のチャレンジ：{doneCount}/{totalSlots} 完了！</p>
        <div className="flex justify-center gap-4 mt-3">
          {Array.from({ length: totalSlots }).map((_, i) => (
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

                {/* 回数バッジ */}
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
                onClick={() => setModalUC(uc)}
                disabled={!week.editable}
                className="w-full bg-[#00A8A5] text-[#F9FAFB]"
              >
                {uc.challenge.title}
              </Button>
            ))}
          </div>
        )}
      </section>

      <CompleteModal
        open={!!modalUC}
        uc={modalUC}
        editable={week.editable}
        onClose={() => setModalUC(null)}
        onSaved={handleSaved}
      />
    </Layout>
  )
}