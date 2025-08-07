// frontend/src/components/DiagnosisForm.jsx
import React, { useState, useEffect } from 'react'
import { fetchQuestions } from '../api'
import Progress from './Progress'

const PAGE_SIZE = 5

export default function DiagnosisForm () {
  const [questions, setQuestions] = useState([])
  const [answers,   setAnswers]   = useState({})
  const [start,     setStart]     = useState(0)
  const [loading,   setLoading]   = useState(true)
  const [error,     setError]     = useState(null)

  /* 質問を取得 */
  useEffect(() => {
    fetchQuestions('full_50')
      .then(data => { setQuestions(data); setLoading(false) })
      .catch(()  => { setError('質問の取得に失敗しました'); setLoading(false) })
  }, [])

  if (loading) return <p className="text-center p-4">読み込み中…</p>
  if (error)   return <p className="text-center p-4 text-red-600 font-semibold">{error}</p>

  const total   = questions.length
  const end     = Math.min(start + PAGE_SIZE, total)
  const visible = questions.slice(start, end)
  const answeredCount = Object.keys(answers).length

  /* ボタン共通クラス（JIT に確実に検出させる）*/
  const btnBase =
    'flex-shrink-0 w-16 h-16 rounded-full border-2 border-[#2B3541] ' +
    'cursor-pointer transition-colors duration-200'

  function handleSelect (uuid, value) {
    setAnswers(prev => {
      const next = { ...prev, [uuid]: value }

      /* このページ(5問)が全て埋まったら自動で次ページ */
      if (
        visible.every(q => next[q.question_uuid] != null) &&
        end < total
      ) {
        setStart(end)
      }
      return next
    })
  }

  function handlePrev () {
    if (start > 0) setStart(Math.max(0, start - PAGE_SIZE))
  }

  return (
    <div className="max-w-[480px] mx-auto p-4">
      <h1 className="text-2xl font-bold text-center mb-6">診断スタート</h1>

      <Progress current={answeredCount} total={total} />

      <ol className="space-y-6 mt-4">
        {visible.map(q => (
          <li key={q.question_uuid} className="text-center border-b border-[#2B3541] pb-6">
            <p className="text-base mb-3">{q.question_body}</p>

            <div className="flex justify-between text-sm text-gray-600 mb-1 px-1">
              <span>当てはまらない</span>
              <span>当てはまる</span>
            </div>

            <div className="flex justify-between">
              {[1, 2, 3, 4, 5].map(n => (
                <button
                  key={n}
                  aria-label={`選択肢 ${n}`}
                  onClick={() => handleSelect(q.question_uuid, n)}
                  className={
                    answers[q.question_uuid] === n
                      ? `${btnBase} bg-[#00A8A5]`
                      : `${btnBase} bg-white hover:bg-gray-200`
                  }
                />
              ))}
            </div>
          </li>
        ))}
      </ol>

      <div className="flex justify-center mt-6">
        <button
          onClick={handlePrev}
          disabled={start === 0}
          className="
            rounded font-semibold text-white
            bg-[#646cff] hover:bg-[#535bf2]
            disabled:opacity-50 disabled:cursor-not-allowed
            py-[0.6em] px-[1.2em]
          "
        >
          前の5問へ
        </button>
      </div>
    </div>
  )
}