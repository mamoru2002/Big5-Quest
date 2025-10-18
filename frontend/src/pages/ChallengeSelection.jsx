import React, { useEffect, useMemo, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import Layout from '../components/Layout'
import Button from '../components/ui/Button'
import { fetchChallenges, createUserChallenges } from '../api'

const TRAIT_LABEL = { N: '情緒安定性', E: '外向性', C: '誠実性' }

export default function ChallengeSelection() {
  const nav = useNavigate()
  const { id, code } = useParams()
  const [all, setAll] = useState([])
  const [selectedIds, setSelectedIds] = useState(new Set())
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    ;(async () => {
      try {
        const list = await fetchChallenges(code)
        setAll(Array.isArray(list) ? list : [])
      } catch (err) {
        console.error(err)
        setError('チャレンジ一覧の取得に失敗しました')
      } finally {
        setLoading(false)
      }
    })()
  }, [code])

  const selected = useMemo(() => all.filter(c => selectedIds.has(c.id)), [all, selectedIds])
  const remain   = useMemo(() => all.filter(c => !selectedIds.has(c.id)), [all, selectedIds])

  function toggle(id) {
    setSelectedIds(prev => {
      const next = new Set(prev)
      if (next.has(id)) {
        next.delete(id)
      } else {
        if (next.size >= 4) return next
        next.add(id)
      }
      return next
    })
  }

  async function handleConfirm() {
    try {
      const ids = Array.from(selectedIds)
      await createUserChallenges(id, ids)
      try {
        localStorage.setItem('focus_trait_code', code)
      } catch (err) {
        console.warn('focus_trait_code save failed', err)
      }
      nav('/dashboard', { replace: true })
    } catch (err) {
      console.error(err)
      setError('確定に失敗しました')
    }
  }

  if (loading) return <p className="text-center p-4">読み込み中…</p>
  if (error)   return <p className="text-center p-4 text-red-600">{error}</p>

  return (
    <Layout>
      <div className="relative flex justify-center items-center py-12 mb-6">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="w-[100px] h-[100px] bg-[#CDEDEC] rounded-full" />
        </div>
        <h1 className="relative text-xl font-bold text-center">
          今週の{TRAIT_LABEL[code]}の<br />チャレンジを選ぼう！
        </h1>
      </div>

      <p className="text-center mt-2 text-sm">
        1週間に、<strong>1〜4個</strong>まで選べます。<br />
        選択中のチャレンジを押すと戻せます。
      </p>

      <div className="mt-4 bg-[#CDEDEC] p-4 rounded-xl">
        <p className="text-center font-semibold">選択中のチャレンジ</p>
        <p className="text-center mb-2">{selected.length}/4</p>

        <div className="p-4 border-2 border-[#2B3541] rounded-xl bg-[#F9FAFB] space-y-3 min-h-[48px]">
          {selected.length === 0 ? (
            <p className="text-sm text-gray-400 text-center">ここに選択したチャレンジが表示されます</p>
          ) : (
            selected.map(c => (
              <Button
                key={c.id}
                onClick={() => toggle(c.id)}
                className="w-full bg-[#00A8A5] text-[#F9FAFB]"
              >
                {c.title}
              </Button>
            ))
          )}
        </div>

        <div className="flex justify-center mt-4">
          <Button
            onClick={handleConfirm}
            disabled={selected.length < 1 || selected.length > 4}
            className="bg-[#F9FAFB] text-[#2B3541] min-w-[120px]"
          >
            確定
          </Button>
        </div>
      </div>

      <div className="text-center mt-6">
        <h2 className="text-lg font-bold">{TRAIT_LABEL[code]}</h2>
        <p className="text-sm mt-1">
          チャレンジ項目を押して選ぼう！<br />
          確実に実行できるように<br />
          無理なく、1つだけでもOK。
        </p>
      </div>

      <div className="mt-4">
        <div className="p-4 border-2 border-[#2B3541] rounded-xl bg-[#F9FAFB] space-y-3">
          {remain.map(c => (
            <Button
              key={c.id}
              onClick={() => toggle(c.id)}
              className="w-full bg-[#00A8A5] text-[#F9FAFB]"
            >
              {c.title}
            </Button>
          ))}
        </div>
      </div>
    </Layout>
  )
}