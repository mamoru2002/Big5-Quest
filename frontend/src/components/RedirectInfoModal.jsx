import React from 'react'
import Button from './ui/Button'

const BASE_STYLES = 'fixed inset-0 z-50 flex items-center justify-center'

export default function RedirectInfoModal({
  open,
  mode = 'diagnosis',
  variant = 'weekly',
  questionCount = null,
  onConfirm,
}) {
  if (!open) return null

  const isRest = mode === 'rest'
  let title
  let body
  let action

  if (isRest) {
    title = '今週はおやすみです'
    body = 'クエストお疲れ様でした！今週は休息期間です。おやすみ画面に移動します。'
    action = '画面へ進む'
  } else {
    switch (variant) {
      case 'final':
        title = '最終週の診断を開始します！'
        body = 'クエストお疲れ様でした！15週間の締めくくりです。今週の診断に進みます！'
        break
      case 'milestone':
        title = '節目週の診断を開始します！'
        body = 'クエストお疲れ様でした！節目の週は特別な診断に取り組みます。今週の診断に進みます！'
        break
      default:
        title = '今週の診断を開始します！'
        body = 'クエストお疲れ様でした！Big5-Quest は週ごとに内容が変わります。今週の診断に進みます！'
        break
    }
    if (typeof questionCount === 'number' && questionCount > 0) {
      body = `${body}\n今週は${questionCount}問です。`
    }
    action = 'はじめる'
  }

  return (
    <div className={BASE_STYLES}>
      <div className="absolute inset-0 bg-black/50" />
      <div className="relative w-[92%] max-w-md rounded-2xl border-2 border-[#2B3541] bg-[#F9FAFB] p-6 text-center shadow-[0_8px_0_#2B3541]">
        <h2 className="text-xl font-bold text-[#2B3541]">{title}</h2>
        <p className="mt-4 text-sm leading-relaxed text-[#2B3541] whitespace-pre-line">{body}</p>
        <div className="mt-6 flex justify-center">
          <Button onClick={onConfirm} className="min-w-[140px] bg-[#00A8A5] text-[#F9FAFB]">
            {action}
          </Button>
        </div>
      </div>
    </div>
  )
}
