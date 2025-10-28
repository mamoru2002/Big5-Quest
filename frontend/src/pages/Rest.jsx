import React from 'react'
import Layout from '../components/Layout'
import Button from '../components/ui/Button'
import { useNavigate } from 'react-router-dom'

export default function Rest() {
  const navigate = useNavigate()

  return (
    <Layout className="text-center pt-8">
      <h1 className="text-2xl font-bold text-[#2B3541]">今週はおやすみです</h1>
      <p className="mt-4 text-sm leading-relaxed text-[#2B3541]">
        今週のクエストはお休み週です。来週から再びチャレンジが再開しますので、
        ゆっくり体調を整えてください。
      </p>
      <div className="mt-8 flex justify-center">
        <Button
          onClick={() => navigate('/dashboard', { replace: true })}
          className="bg-[#00A8A5] text-[#F9FAFB] px-6"
        >
          ダッシュボードに戻る
        </Button>
      </div>
    </Layout>
  )
}
