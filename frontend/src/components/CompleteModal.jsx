import React, { useEffect, useState } from 'react'
import Button from './ui/Button'
import { fetchEmotionTags, updateUserChallenge } from '../api'

export default function CompleteModal({
  open,
  uc,
  editable,
  onClose,
  onSaved,
}) {
  const [comment, setComment] = useState('')
  const [tagOptions, setTagOptions] = useState([])
  const [selectedTagIds, setSelectedTagIds] = useState(new Set())
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!open) return
    setComment('')
    setSelectedTagIds(new Set())
    setError(null)

    ;(async () => {
      try {
        const tags = await fetchEmotionTags().catch(() => [])
        const normalized = (tags || []).map(t => ({
          id: t.id,
          label: t.name || t.name_ja || t.name_en || `#${t.id}`,
        }))
        setTagOptions(normalized)
      } catch (e) {
        console.error(e)
        setTagOptions([])
      }
    })()
  }, [open])

  if (!open || !uc) return null

  const toggleTag = (id) => {
    setSelectedTagIds(prev => {
      const next = new Set(prev)
      next.has(id) ? next.delete(id) : next.add(id)
      return next
    })
  }

  const submit = async () => {
    if (!editable) return
    setSaving(true)
    setError(null)

    const payload = {
      status: 'expired',
      exec_count: Math.max(1, uc.exec_count || 0),
      comment,
      emotion_tag_ids: Array.from(selectedTagIds),
    }

    try {
      await updateUserChallenge(uc.id, payload)
      onSaved?.(uc.id, { status: 'expired', exec_count: payload.exec_count })
      onClose?.()
    } catch (e) {
      console.error('updateUserChallenge failed', e)
      setError('更新に失敗しました')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/50" onClick={() => !saving && onClose?.()} />
      <div className="relative w-[92%] max-w-md rounded-2xl border-2 border-[#2B3541] bg-[#F9FAFB] shadow-[0_8px_0_#2B3541] p-5">
        <h3 className="text-lg font-bold text-center">完了メモを追加</h3>
        <p className="mt-2 text-sm text-center text-[#2B3541]">
          {uc.challenge?.title}
        </p>

        <label className="block mt-4 text-sm font-semibold">
          コメント（任意）
        </label>
        <textarea
          value={comment}
          onChange={e => setComment(e.target.value)}
          rows={4}
          className="mt-1 w-full rounded-xl border-2 border-[#2B3541] bg-white p-3 outline-none"
          placeholder="やってみてどうだった？メモしておこう"
        />

        <div className="mt-4">
          <div className="text-sm font-semibold">タグ（複数選択可）</div>
          <div className="mt-2 flex flex-wrap gap-2">
            {tagOptions.map(t => {
              const active = selectedTagIds.has(t.id)
              return (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => toggleTag(t.id)}
                  className={
                    'px-3 py-1 rounded-full border-2 border-[#2B3541] ' +
                    (active ? 'bg-[#00A8A5] text-[#F9FAFB]' : 'bg-white')
                  }
                >
                  {t.label}
                </button>
              )
            })}
            {tagOptions.length === 0 && (
              <span className="text-xs text-gray-500">タグ候補は未登録です</span>
            )}
          </div>
        </div>

        {error && <p className="mt-3 text-sm text-red-600">{error}</p>}

        <div className="mt-5 flex gap-3 justify-center">
          <Button
            onClick={submit}
            disabled={saving || !editable}
            className="bg-[#00A8A5] text-[#F9FAFB] min-w-[120px]"
          >
            {saving ? '保存中…' : '保存して完了'}
          </Button>
          <Button
            onClick={onClose}
            disabled={saving}
            className="bg-[#F9FAFB] text-[#2B3541] min-w-[100px]"
          >
            キャンセル
          </Button>
        </div>
      </div>
    </div>
  )
}