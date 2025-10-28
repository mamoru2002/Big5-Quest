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
import formsMapData from '../../../db/seeds/forms_map.json'

const REDIRECT_KEY_PREFIX = 'weekly_redirect_done'
const SKIP_SCHEDULE_PREFIX = 'weekly_skip_scheduled'
const FORM_STORAGE_PREFIX = 'weekly_form_choice'

function storageAvailable() {
  try {
    return typeof window !== 'undefined' && !!window.localStorage
  } catch (e) {
    console.debug('localStorage unavailable', e)
    return false
  }
}

function parseWeekStart(startAt) {
  if (!startAt) return null
  try {
    if (typeof startAt === 'string' && /^\d{4}-\d{2}-\d{2}/.test(startAt)) {
      return new Date(`${startAt}T00:00:00Z`)
    }
    const parsed = new Date(startAt)
    if (Number.isNaN(parsed.getTime())) return null
    return parsed
  } catch (e) {
    console.debug('parseWeekStart error', e)
    return null
  }
}

function toISODateString(date) {
  if (!(date instanceof Date) || Number.isNaN(date.getTime())) return null
  return date.toISOString().split('T')[0]
}

function buildWeekKey(startAt) {
  const parsed = parseWeekStart(startAt)
  if (!parsed) return null
  return toISODateString(parsed)
}

function computeNextWeekKey(startAt) {
  const parsed = parseWeekStart(startAt)
  if (!parsed) return null
  const next = new Date(parsed.getTime())
  next.setUTCDate(next.getUTCDate() + 7)
  return toISODateString(next)
}

function redirectKey(userId, weekKey) {
  return `${REDIRECT_KEY_PREFIX}:${userId}:${weekKey}`
}

function skipKey(userId, weekKey) {
  return `${SKIP_SCHEDULE_PREFIX}:${userId}:${weekKey}`
}

function hasRedirectedForWeek(userId, weekKey) {
  if (!userId || !weekKey || !storageAvailable()) return false
  try {
    return window.localStorage.getItem(redirectKey(userId, weekKey)) === '1'
  } catch (e) {
    console.debug('hasRedirectedForWeek error', e)
    return false
  }
}

function markRedirectedForWeek(userId, weekKey) {
  if (!userId || !weekKey || !storageAvailable()) return
  try {
    window.localStorage.setItem(redirectKey(userId, weekKey), '1')
  } catch (e) {
    console.debug('markRedirectedForWeek error', e)
  }
}

function markScheduledSkip(userId, weekKey, active) {
  if (!userId || !weekKey || !storageAvailable()) return
  try {
    if (active) {
      window.localStorage.setItem(skipKey(userId, weekKey), '1')
    } else {
      window.localStorage.removeItem(skipKey(userId, weekKey))
    }
  } catch (e) {
    console.debug('markScheduledSkip error', e)
  }
}

function isWeekScheduledToSkip(userId, weekKey) {
  if (!userId || !weekKey || !storageAvailable()) return false
  try {
    return window.localStorage.getItem(skipKey(userId, weekKey)) === '1'
  } catch (e) {
    console.debug('isWeekScheduledToSkip error', e)
    return false
  }
}

function buildFormStorageKey(userId, programWeek) {
  if (!userId && userId !== 0) return null
  if (programWeek == null) return null
  return `${FORM_STORAGE_PREFIX}:${userId}:${programWeek}`
}

function fallbackFull50(reason) {
  if (reason) {
    console.warn('[weeklyForms] fallback to full_50', reason)
  }
  const questions = Array.isArray(formsMapData?.full_50) ? [...formsMapData.full_50] : []
  return { formName: 'full_50', questionUuids: questions }
}

function normalizeTrait(code) {
  if (typeof code !== 'string') return null
  const upper = code.trim().toUpperCase()
  return ['E', 'C', 'N'].includes(upper) ? upper : null
}

function normalizeBucket(bucket) {
  if (typeof bucket !== 'string') return null
  const upper = bucket.trim().toUpperCase()
  return ['A', 'B', 'C'].includes(upper) ? upper : null
}

function selectWeeklyForm({
  focus_trait_code,
  is_milestone_26,
  milestone_bucket,
  is_final_full50,
  rotation_bucket,
}) {
  if (is_final_full50) {
    return fallbackFull50(null)
  }

  const trait = normalizeTrait(focus_trait_code)
  if (!trait) {
    return fallbackFull50('focus_trait_code missing')
  }

  if (is_milestone_26) {
    const bucket = normalizeBucket(milestone_bucket)
    if (!bucket || !['A', 'B'].includes(bucket)) {
      return fallbackFull50('milestone bucket missing')
    }
    const questions = formsMapData?.milestone_26?.[trait]?.[bucket]
    if (!Array.isArray(questions) || questions.length === 0) {
      return fallbackFull50(`missing milestone map for ${trait}/${bucket}`)
    }
    return {
      formName: `milestone_26_${trait.toLowerCase()}_${bucket.toLowerCase()}`,
      questionUuids: [...questions],
    }
  }

  const bucket = normalizeBucket(rotation_bucket) || 'A'
  const questions = formsMapData?.target_forms?.[trait]?.[bucket]
  if (!Array.isArray(questions) || questions.length === 0) {
    return fallbackFull50(`missing target form for ${trait}/${bucket}`)
  }
  return {
    formName: `target_forms_${trait.toLowerCase()}_${bucket.toLowerCase()}`,
    questionUuids: [...questions],
  }
}

function loadWeeklyFormChoice(userId, programWeek) {
  const key = buildFormStorageKey(userId, programWeek)
  if (!key || !storageAvailable()) return null
  try {
    const raw = window.localStorage.getItem(key)
    if (!raw) return null
    const parsed = JSON.parse(raw)
    if (!parsed || typeof parsed !== 'object') return null
    const formName = typeof parsed.formName === 'string' ? parsed.formName : null
    const questionUuids = Array.isArray(parsed.questionUuids) ? parsed.questionUuids : []
    if (!formName) return null
    return { formName, questionUuids }
  } catch (e) {
    console.debug('loadWeeklyFormChoice error', e)
    return null
  }
}

function saveWeeklyFormChoice(userId, programWeek, payload) {
  const key = buildFormStorageKey(userId, programWeek)
  if (!key || !storageAvailable()) return
  try {
    const data = {
      formName: payload?.formName,
      questionUuids: Array.isArray(payload?.questionUuids) ? payload.questionUuids : [],
    }
    window.localStorage.setItem(key, JSON.stringify(data))
  } catch (e) {
    console.debug('saveWeeklyFormChoice error', e)
  }
}

const FOCUS_TRAIT_STORAGE_KEY = 'focus_trait_code'

function readStoredFocusTrait() {
  try {
    if (typeof window === 'undefined') return null
    const value = window.localStorage.getItem(FOCUS_TRAIT_STORAGE_KEY)
    return value ? value.toUpperCase() : null
  } catch (e) {
    console.debug('focus_trait_code read failed', e)
    return null
  }
}

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

  const [formChoice, setFormChoice] = useState(null)
  const [formReady, setFormReady] = useState(false)

  const [autoHandled, setAutoHandled] = useState(false)
  const [redirectModal, setRedirectModal] = useState({
    open: false,
    mode: 'diagnosis',
    target: null,
    weekKey: null,
    variant: 'weekly',
    questionCount: null,
  })

  const programWeek = typeof week?.program_week === 'number' ? week.program_week : null
  const pausedThisWeek = typeof week?.paused === 'boolean' ? week.paused : false
  const weekFocusTrait = typeof week?.focus_trait_code === 'string' ? week.focus_trait_code : null
  const isMilestoneWeek = Boolean(week?.is_milestone_26)
  const milestoneBucket = week?.milestone_bucket ?? null
  const isFinalWeek = Boolean(week?.is_final_full50)
  const rotationBucket = week?.rotation_bucket ?? null

  useEffect(() => {
    let active = true
    ;(async () => {
      try {
        const data = await fetchCurrentWeek()
        if (!active) return
        setWeek(data || null)
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
    if (!userId) return

    setFormReady(false)

    if (programWeek == null) {
      setFormChoice(null)
      setFormReady(true)
      return
    }

    if (pausedThisWeek) {
      setFormChoice(null)
      setFormReady(true)
      return
    }

    const existing = loadWeeklyFormChoice(userId, programWeek)
    if (existing) {
      setFormChoice(existing)
      setFormReady(true)
      return
    }

    const focusCandidate = weekFocusTrait || readStoredFocusTrait()
    const selection = selectWeeklyForm({
      focus_trait_code: focusCandidate,
      is_milestone_26: isMilestoneWeek,
      milestone_bucket: milestoneBucket,
      is_final_full50: isFinalWeek,
      rotation_bucket: rotationBucket,
    })

    setFormChoice(selection)
    if (selection?.formName) {
      saveWeeklyFormChoice(userId, programWeek, selection)
    }
    setFormReady(true)
  }, [
    userId,
    programWeek,
    pausedThisWeek,
    weekFocusTrait,
    isMilestoneWeek,
    milestoneBucket,
    isFinalWeek,
    rotationBucket,
  ])

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

    if (!isPaused && !formReady) {
      return
    }

    const resolvedFormName = !isPaused
      ? formChoice?.formName || 'full_50'
      : null
    const params = new URLSearchParams()
    if (resolvedFormName) params.set('form', resolvedFormName)
    if (week.result_id) params.set('result_id', week.result_id)
    const diagnosisTarget = `/diagnosis${params.toString() ? `?${params.toString()}` : ''}`
    const questionCount = Array.isArray(formChoice?.questionUuids)
      ? formChoice.questionUuids.length
      : null
    const variant = isFinalWeek ? 'final' : isMilestoneWeek ? 'milestone' : 'weekly'

    if (isPaused) {
      if (!alreadyRedirected) {
        setRedirectModal({
          open: true,
          mode: 'rest',
          target: '/rest',
          weekKey,
          variant: 'rest',
          questionCount: null,
        })
      } else {
        navigate('/rest', { replace: true })
      }
      setAutoHandled(true)
      return
    }

    if (!alreadyRedirected) {
      setRedirectModal({
        open: true,
        mode: 'diagnosis',
        target: diagnosisTarget,
        weekKey,
        variant,
        questionCount,
      })
      setAutoHandled(true)
      return
    }

    if (diagnosisStatus === 'incomplete') {
      navigate(diagnosisTarget, { replace: true })
    }

    setAutoHandled(true)
  }, [
    autoHandled,
    week,
    userReady,
    skipReady,
    diagnosisReady,
    skipFailed,
    userId,
    navigate,
    diagnosisStatus,
    formReady,
    formChoice,
    isFinalWeek,
    isMilestoneWeek,
  ])

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
        variant={redirectModal.variant}
        questionCount={redirectModal.questionCount}
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