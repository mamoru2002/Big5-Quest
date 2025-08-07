import React from 'react'
import { useLocation, useParams } from 'react-router-dom'

export default function ResultPage() {
  const { id } = useParams()           // URL の :id
  const { state } = useLocation()      // navigate で渡した state
  const scores = state?.scores || {}

  return (
    <div className="max-w-[480px] mx-auto p-4">
      <h1 className="text-2xl font-bold text-center mb-6">診断結果</h1>
      <p>診断ID: {id}</p>

      <ul className="mt-4 space-y-2">
        {Object.entries(scores).map(([trait, score]) => (
          <li key={trait} className="flex justify-between">
            <span>{trait}</span>
            <span>{score}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}