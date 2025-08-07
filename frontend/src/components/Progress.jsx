import React from 'react'

export default function Progress({ current, total }) {
  const percent = Math.round((current / total) * 100)

  return (
    <div className="max-w-sm mx-auto mb-4">
      {/* 数字表示 */}
      <div className="text-center font-bold mb-2">
        {current}/{total}
      </div>

      {/* 外枠 */}
      <div className="w-full h-2 border-2 border-teal-600 rounded bg-white overflow-hidden">
        {/* 中身 */}
        <div
          className="h-full bg-teal-600 transition-all duration-300 ease-in-out"
          style={{ width: `${percent}%` }}
        />
      </div>
    </div>
  )
}