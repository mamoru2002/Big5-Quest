import React, { useMemo } from 'react'
import { useLocation, useNavigate, useParams } from 'react-router-dom'
import Layout from '../components/Layout'
import Button from '../components/ui/Button'
import RadarChart from '../components/RadarChart'

const TRAITS = [
  {
    code: 'N',
    label: '情緒安定性',
    desc: '不安やストレスへの耐性に関する傾向です。心を安定させたいなら。'
  },
  {
    code: 'E',
    label: '外向性',
    desc: '人との交流や積極性に関する傾向です。もっと社交的になりたいなら。'
  },
  {
    code: 'C',
    label: '誠実性',
    desc: '計画性や自己管理、努力に関する傾向です。継続力を高めたいなら。'
  }
]

export default function ResultPage() {
  const { id } = useParams()
  const { state } = useLocation()
  const nav = useNavigate()

  const scores = useMemo(() => state?.scores || {}, [state?.scores])

  const recommended = useMemo(() => {
    const targetCodes = ['N', 'E', 'C']
    const items = targetCodes
      .map(code => ({ code, value: Number(scores?.[code]) }))
      .filter(x => !Number.isNaN(x.value))
    if (!items.length) return null
    return items.reduce((min, cur) => (cur.value < min.value ? cur : min))
  }, [scores])

  const traitByCode = code => TRAITS.find(t => t.code === code)

  return (
    <Layout>

        <div className="relative flex justify-center items-center py-12">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <div className="w-[100px] h-[100px] bg-[#CDEDEC] rounded-full" />
          </div>
          <h1 className="relative text-2xl text-center">
            診断結果を元に15週間で<br/>どの特性を伸ばすか選ぼう！
          </h1>
        </div>

      <div className="mb-6">
        <RadarChart scores={scores} />
      </div>

      <h1 className="text-2xl font-bold text-center mb-4">伸ばしたい特性を選びましょう</h1>

      <p className="text-sm text-[#2B3541]/70 leading-relaxed mb-4">
        自分が「こうなりたい」と思う特性を選ぶのが一番のおすすめです。
      </p>

      <div className="flex flex-col gap-3">
        {TRAITS.map(t => (
          <Button
            key={t.code}
            className="w-full bg-[#00A8A5] text-[#F9FAFB] border-[#2B3541]"
            onClick={() => nav(`/select/${id}/${t.code}`)}
          >
            <div className="text-center">
              <div className="text-xl font-semibold">{t.label}</div>
              <div className="text-sm mt-1 opacity-90 leading-relaxed">
                {t.desc.split('。').map((chunk, i, arr) =>
                  chunk ? (
                    <span key={i}>
                      {chunk}。
                      {i < arr.length - 1 && <br />}
                    </span>
                  ) : null
                )}
              </div>
            </div>
          </Button>
        ))}
      </div>

      <hr className="border-t border-[#2B3541]/30 my-6" />

      <div className="text-center mb-3">
        <div className="text-sm text-[#2B3541] mb-1">もし迷ったら？</div>
        {recommended && (
          <div className="text-[#2B3541] text-base">
            あなたは
            <span className="font-semibold">
              {traitByCode(recommended.code)?.label}
            </span>
            を伸ばすのがおすすめ！
          </div>
        )}
      </div>

      {recommended && (
        <Button
          className="w-full bg-[#00A8A5] text-white border-[#2B3541]"
          onClick={() => nav(`/select/${id}/${recommended.code}`)}
        >
          <div className="text-center">
            <div className="text-xl font-semibold">
              {traitByCode(recommended.code)?.label}
            </div>
            <div className="text-sm mt-1 opacity-90 leading-relaxed">
              {traitByCode(recommended.code)?.desc}
            </div>
          </div>
        </Button>
      )}
    </Layout>
  )
}