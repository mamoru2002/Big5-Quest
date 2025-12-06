import React, { useEffect, useMemo, useState } from 'react';
import TraitDeltaChart from '../components/TraitDeltaChart';
import ToggleSwitch from '../components/ui/ToggleSwitch';
import Button from '../components/ui/Button';
import {
  fetchMe,
  fetchStatsSummary,
  fetchTraitHistory,
  fetchWeekSkipStatus,
  updateWeekSkip,
  fetchChallengeHistory,
} from '../api';
import { fetchProfile, saveProfile } from '../api/profile';

const COLORS = { teal: '#00A8A5', ink: '#2B3541', mint: '#CDEDEC', bg: '#F9FAFB' };
const FOCUS_KEY = 'focus_trait_code';

const TRAIT_LABEL = {
  N: '情緒安定性',
  E: '外向性',
  C: '誠実性',
};

function getFocusCode() {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      const v = window.localStorage.getItem(FOCUS_KEY);
      return v || null;
    }
  } catch (e) {
    console.debug('localStorage error', e);
  }
  return null;
}

export default function MyPage() {
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState('');
  const [me, setMe] = useState(null);
  const [summary, setSummary] = useState(null);
  const [profile, setProfile] = useState({ name: '', bio: '' });
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);

  const [skipInfo, setSkipInfo] = useState({ remaining: 0, used: 0, max: 3, next_week_paused: false });
  const [usedBase, setUsedBase] = useState(0);
  const [skipChecked, setSkipChecked] = useState(false);
  const [skipPending, setSkipPending] = useState(false);

  const [traitCode, setTraitCode] = useState(null);
  const [points, setPoints] = useState([]);
  const [challengeHistory, setChallengeHistory] = useState([]);

  const displayName = useMemo(() => {
    const n = profile?.name?.trim();
    if (n) return n;
    const emailLocal = me?.email ? me.email.split('@')[0] : '';
    return emailLocal || 'hogename';
  }, [me, profile]);

  useEffect(() => {
    (async () => {
      try {
        const [meRes, summaryRes, skipResRaw, profRes] = await Promise.all([
          fetchMe(),
          fetchStatsSummary(),
          fetchWeekSkipStatus(),
          fetchProfile().catch(() => ({ name: '', bio: '' })),
        ]);
        setMe(meRes);
        setSummary(summaryRes);

        const safeSkip = skipResRaw || { remaining: 0, used: 0, max: 3, next_week_paused: false };
        setSkipInfo(safeSkip);
        setSkipChecked(Boolean(safeSkip.next_week_paused));
        setUsedBase(Number(safeSkip.used || 0));

        setProfile({ name: profRes?.name || '', bio: profRes?.bio || '' });

        const code = getFocusCode();
        if (!code) {
          alert('初回の「伸ばす特性」選択が見つかりませんでした。診断〜特性選択を先に完了してください。');
        } else {
          setTraitCode(code);
        }
      } catch (e) {
        console.error(e);
        setErr(`データの取得に失敗しました: ${e?.message || ''}`);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  useEffect(() => {
    (async () => {
      if (!traitCode) {
        setPoints([]);
        return;
      }
      try {
        const hist = await fetchTraitHistory(traitCode);
        setPoints(Array.isArray(hist?.points) ? hist.points : []);
      } catch (e) {
        console.error(e);
        setPoints([]);
      }
    })();
  }, [traitCode]);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetchChallengeHistory();
        const items = Array.isArray(res?.items) ? res.items : [];
        setChallengeHistory(items);
      } catch (e) {
        console.error(e);
        setChallengeHistory([]);
      }
    })();
  }, []);

  const onToggleSkip = async (vOrBool) => {
    if (skipPending) return;
    const next = typeof vOrBool === 'boolean' ? vOrBool : !skipChecked;

    setSkipPending(true);
    const prev = skipChecked;
    setSkipChecked(next);

    try {
      const res = await updateWeekSkip(next);
      const effective = res && typeof res.next_week_paused === 'boolean' ? res.next_week_paused : next;

      if (effective !== next) {
        setSkipChecked(prev);
        alert('スキップ予約を受け付けられませんでした。時間をおいて再度お試しください。');
        return;
      }

      setSkipInfo((s) => ({ ...s, next_week_paused: effective }));
    } catch (e) {
      console.error(e);
      setSkipChecked(prev);
      alert('スキップ設定の更新に失敗しました。');
    } finally {
      setSkipPending(false);
    }
  };

  const onSaveProfile = async () => {
    if (saving) return;
    setSaving(true);
    try {
      const payload = { name: profile.name || '', bio: profile.bio || '' };
      const saved = await saveProfile(payload);
      setProfile({ name: saved?.name || payload.name, bio: saved?.bio || payload.bio });
      setEditing(false);
    } catch (e) {
      console.error(e);
      alert('プロフィールの保存に失敗しました。');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <p className="text-center p-4">読み込み中…</p>;
  if (err) return <p className="text-center p-4 text-red-600">{err}</p>;

  const displayedRemaining = (skipInfo.max ?? 3) - usedBase;

  return (
    <div style={{ background: COLORS.bg, color: COLORS.ink }}>
      <div className="mx-auto w-full max-w-[390px] lg:max-w-[900px] px-5 pb-10 pt-4">
        <section className="text-center">
          <h1 className="text-[24px] font-medium">マイページ</h1>
          <p className="mt-1 text-[24px] font-medium">{displayName}さん</p>
        </section>

        <section className="mt-4 flex justify-center">
          {editing ? (
            <div className="w-[330px] bg-white rounded-[10px] border-[3px] border-[#2B3541] px-4 py-3">
              <div className="space-y-3">
                <input
                  type="text"
                  value={profile.name}
                  onChange={(ev) => setProfile((p) => ({ ...p, name: ev.target.value }))}
                  className="w-full h-[36px] rounded-[5px] px-3 outline-none border border-[#2B3541]"
                  placeholder="ニックネーム"
                />
                <textarea
                  value={profile.bio}
                  onChange={(ev) => setProfile((p) => ({ ...p, bio: ev.target.value }))}
                  className="w-full h-[75px] rounded-[5px] px-3 py-2 outline-none border border-[#2B3541]"
                  placeholder="自己紹介（任意）"
                />
                <div className="flex flex-row flex-nowrap justify-center gap-3 mt-1">
                  <Button
                    onClick={onSaveProfile}
                    disabled={saving}
                    className="whitespace-nowrap h-[36px] px-4 bg-[#00A8A5] text-white"
                  >
                    保存
                  </Button>
                  <Button
                    onClick={() => setEditing(false)}
                    disabled={saving}
                    className="whitespace-nowrap h-[36px] px-4 bg-white text-[#2B3541] border-[#2B3541]"
                  >
                    キャンセル
                  </Button>
                </div>
              </div>
            </div>
          ) : (
            <div className="w-[330px] min-h-[75px] bg-white rounded-[10px] border-[3px] border-[#2B3541] px-4 py-3 text-[16px] leading-snug">
              {profile.bio?.trim() ? profile.bio : '自己紹介は未設定です。'}
            </div>
          )}
        </section>

        {!editing && (
          <section className="mt-3 flex justify-center">
            <Button
              onClick={() => setEditing(true)}
              className="w-[182px] h-[30px] bg-white rounded-[10px] border-[2px] border-[#2B3541] shadow-[0_4px_0_#000] text-[16px] whitespace-nowrap"
            >
              プロフィール編集
            </Button>
          </section>
        )}

        <section className="mt-6 rounded-[10px] px-4 py-4" style={{ background: COLORS.mint }}>
          <div className="mx-auto w-[318px] bg-white rounded-[10px] border-[2px] border-[#2B3541] px-5 py-4">
            <div className="text-[20px]">達成クエスト種類数: {summary?.total_completed ?? 0}</div>
            <div className="text-[20px]">クエスト実行数: {summary?.total_exec ?? 0}</div>
            <div className="text-[20px]">累計達成期間: {summary?.total_weeks_with_any_completion ?? 0}週間</div>
          </div>
        </section>

        <section className="mt-6">
            <h2 className="text-center text-[20px]">
              {traitCode && TRAIT_LABEL[traitCode]
                ? `${TRAIT_LABEL[traitCode]}の変化`
                : '特性の変化'}
            </h2>
          <div className="mt-2 mx-auto w-full bg-white rounded-[5px] border-[2px] border-[#2B3541] px-3 py-3">
            {traitCode ? (
              <TraitDeltaChart points={points} />
            ) : (
              <div className="text-center py-8 text-sm text-gray-600">特性が未設定のため、グラフは表示できません。</div>
            )}
          </div>
          <p className="mt-3 text-[16px]">
            差分グラフは、最初の週（W0）を基準に、その後の各週でスコアがどれだけ変化したかを視覚化したものです。+2以上の上昇があれば「かなり変化した」と言える目安になります。
          </p>
        </section>

        <section className="mt-6">
          <h2 className="text-[20px] text-center">これまでのチャレンジ</h2>

          <div className="mt-3 mx-auto w-full max-w-[700px] bg-white rounded-[10px] border-[2px] border-[#2B3541] px-4 py-4">
            {challengeHistory.length === 0 ? (
              <p className="text-center text-sm text-gray-500">
                まだ実行済みのチャレンジはありません。
              </p>
            ) : (
              <ul className="space-y-3">
                {challengeHistory.map((item) => (
                  <li
                    key={item.id}
                    className="border border-[#CDEDEC] rounded-[8px] px-3 py-2 bg-[#F9FAFB]"
                  >
                    <div className="text-sm font-semibold">
                      {item.title}
                    </div>

                    {item.first_done_at && (
                      <div className="mt-1 text-xs text-gray-500">
                        初回達成日:{' '}
                        {new Date(item.first_done_at).toLocaleDateString('ja-JP')}
                        {' '} / 実行 {item.exec_count} 回
                      </div>
                    )}

                    {item.tags && item.tags.length > 0 && (
                      <div className="mt-1 flex flex-wrap gap-1 text-xs">
                        {item.tags.map((tag) => (
                          <span
                            key={tag.id}
                            className="px-2 py-[2px] rounded-full bg-[#CDEDEC] text-[#2B3541]"
                          >
                            {tag.name}
                          </span>
                        ))}
                      </div>
                    )}

                    {item.comment && (
                      <p className="mt-2 text-sm whitespace-pre-wrap">
                        {item.comment}
                      </p>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </section>

        <section className="mt-6">
          <h2 className="text-[20px] text-center">来週のクエストをスキップする</h2>
            <div className="mt-3 flex justify-center">
            <ToggleSwitch
                checked={skipChecked}
                disabled={skipPending}
                onChange={onToggleSkip}
                labelLeft="スキップ:"
                labelRight={skipChecked ? 'スキップする' : 'スキップしない'}
            />
            </div>
          <div className="mt-2 text-center text-[16px] font-medium">
            残り {displayedRemaining} / {skipInfo.max ?? 3}
          </div>
          <p className="mt-3 text-[16px]">
            スキップすると「次の週を丸ごと休止」として予約されます。今週の進捗はそのまま続行。週が切り替わった時点で次回の週が休止になり、診断やクエストはスキップされます（休止は最大3回まで）。
          </p>
        </section>
      </div>
    </div>
  );
}