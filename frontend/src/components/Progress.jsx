import React from 'react'

export default function Progress({ current, total }) {
  const percent = Math.round((current / total) * 100)

  return (
    <div className="max-w-sm mx-auto mb-4">
      <div className="text-center font-bold mb-2">
        {current}/{total}
      </div>

      <div className="w-full h-3 border-2 border-teal-600 rounded-2xl bg-white overflow-hidden">
        <div
          className="h-full bg-teal-600 transition-all rounded-2xl duration-300 ease-in-out"
          style={{ width: `${percent}%` }}
        />
      </div>
    </div>
  )
}