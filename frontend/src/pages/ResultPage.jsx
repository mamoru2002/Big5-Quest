import React, { useEffect, useState } from 'react';
import { useParams, useLocation } from 'react-router-dom';
import RadarChart from '../components/RadarChart';
import { fetchResultScores } from '../api';
// frontend/src/pages/ResultPage.jsx
export default function ResultPage() {
  const { id } = useParams();
  const { state } = useLocation();
  const [scores, setScores] = useState(state?.scores || null);
  const [error, setError]   = useState(null);

  useEffect(() => {
    if (!scores && id) {
      fetchResultScores(id)
        .then(setScores)
        .catch(() => setError('スコアの取得に失敗しました'));
    }
  }, [id, scores]);

  if (error)   return <p className="text-red-600">{error}</p>;
  if (!scores) return <p>読み込み中…</p>;

  return (
    <div>
      <h1>診断結果</h1>
      <RadarChart scores={scores} />
      {/* 特性選択 */}
    </div>
  );
}