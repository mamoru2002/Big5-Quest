import React, { useMemo } from 'react'
import { useLocation, useNavigate, useParams } from 'react-router-dom'
import Layout from '../components/Layout'
import Button from '../components/ui/Button'
import RadarChart from '../components/RadarChart'

const TRAIT_SUMMARIES = [
  {
    code: 'N',
    label: '情緒安定性',
    summary: '気持ちの安定しやすさや、ストレスへの強さに関する特性です。',
    high: '気持ちが安定していて、ストレスがかかっても立て直しやすいタイプです。',
    low: '不安や落ち込みを感じやすく、気持ちが揺れやすいタイプです。'
  },
  {
    code: 'E',
    label: '外向性',
    summary: '人との交流や、どれくらい積極的に動くかに関する特性です。',
    high: '人と話したり、場の中心にいることでエネルギーを得やすいタイプです。',
    low: '一人の時間で回復しやすく、人混みや大勢の場が少し疲れやすいタイプです。'
  },
  {
    code: 'O',
    label: '開放性',
    summary: '新しい経験やアイデアへの好奇心・柔軟さに関する特性です。',
    high: '新しい考え方や体験が好きで、色々試してみたいタイプです。',
    low: '慣れたやり方や決まったパターンを大事にするタイプです。'
  },
  {
    code: 'A',
    label: '協調性',
    summary: '人への優しさや、相手に合わせようとする度合いに関する特性です。',
    high: '相手の気持ちを大切にし、衝突を避けて穏やかに関わろうとするタイプです。',
    low: 'ハッキリ自分の意見を言いやすく、ときに競争的になりやすいタイプです。'
  },
  {
    code: 'C',
    label: '誠実性',
    summary: '計画性や自己管理、やり抜く力に関する特性です。',
    high: 'コツコツ取り組むのが得意で、約束や計画をきちんと守りやすいタイプです。',
    low: 'その場のノリや気分で動きやすく、予定通りに進めるのが少し苦手なタイプです。'
  }
]

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

      <div className="mt-2 mb-8">
        <h2 className="text-lg font-semibold text-center mb-2">
          5つの特性について
        </h2>
        <p className="text-xs text-[#2B3541]/70 text-center mb-4">
          それぞれの特性は「高い」「低い」でいい・悪いが決まるものではなく、
          あなたの性格の傾向を表しています。
        </p>

        <div className="grid gap-3 md:grid-cols-2">
          {TRAIT_SUMMARIES.map(trait => (
            <div
              key={trait.code}
              className="rounded-xl border border-[#2B3541]/10 bg-white/70 p-3 text-xs leading-relaxed"
            >
              <div className="font-semibold text-sm mb-1">
                {trait.label}
              </div>
              <div className="mb-1">
                {trait.summary}
              </div>
              <div className="mb-0.5">
                <span className="font-semibold">高いと：</span>
                {trait.high}
              </div>
              <div>
                <span className="font-semibold">低いと：</span>
                {trait.low}
              </div>
            </div>
          ))}
        </div>
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