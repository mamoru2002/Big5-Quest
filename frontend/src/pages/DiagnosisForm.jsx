import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  fetchQuestions,
  startDiagnosis,
  submitAnswers,
  completeDiagnosis,
} from '../api';
import Progress from '../components/Progress';
import Button from '../components/ui/Button';
import Layout from '../components/Layout';

const PAGE_SIZE = 5;

export default function DiagnosisForm() {
  const [resultId, setResultId] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers,   setAnswers]   = useState({});
  const [start,     setStart]     = useState(0);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);
  const navigate = useNavigate();
  const [search] = useSearchParams();
  const formName      = search.get('form') || 'guest_10';
  const resultIdParam = search.get('result_id');

  useEffect(() => {
    (async () => {
      try {
        const data = await fetchQuestions(formName);
        setQuestions(data);
      } catch (e) {
        console.error('fetchQuestions error', e);
        setError(`質問の取得に失敗しました\nHTTP ${e.response?.status || ''} ${e.message}`);
        setLoading(false);
        return;
      }

      try {
        if (resultIdParam) {
          setResultId(Number(resultIdParam));
        } else {
          // result_id が無ければ formName で新規開始
          const id = await startDiagnosis(formName);
          setResultId(id);
        }
      } catch (err) {
        console.error('startDiagnosis error object:', err);
        setError(
          `診断開始に失敗しました\nHTTP ${err.response?.status}\n` +
          `${err.response?.data?.error || err.message}`
        );
        setLoading(false);
        return;
      }

      setLoading(false);
    })();
  }, [formName, resultIdParam]);

  if (loading) return <p className="text-center p-4">読み込み中…</p>;
  if (error)   return <p className="text-center p-4 text-red-600 font-semibold whitespace-pre-line">{error}</p>;

  const total   = questions.length;
  const end     = Math.min(start + PAGE_SIZE, total);
  const visible = questions.slice(start, end);
  const answeredCount = Object.keys(answers).length;

  const btnBase =
    'flex-shrink-0 w-12 h-12 rounded-full border-2 border-[#2B3541] ' +
    'cursor-pointer transition-colors duration-200';

  function handleSelect(uuid, value) {
    if (!resultId) return;
    setAnswers(prev => {
      const next = { ...prev, [uuid]: value };

      if (visible.every(q => next[q.question_uuid] != null)) {
        const payload = visible.map(q => ({
          question_uuid: q.question_uuid,
          value:         next[q.question_uuid],
        }));

        submitAnswers(resultId, payload).catch(err =>
          console.error('submitAnswers error', err)
        );

        if (end < total) {
          setStart(end);
          // ページ切り替え後に上へスクロール
          setTimeout(() => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
          }, 0);
        }
      }
      return next;
    });
  }

  function handlePrev() {
    if (start > 0) setStart(Math.max(0, start - PAGE_SIZE));
  }

  async function handleFinish() {
    try {
      const scores = await completeDiagnosis(resultId);
      navigate(`/result/${resultId}`, { state: { scores } });
    } catch (e) {
      console.error('診断完了エラー', e);
      setError('結果送信に失敗しました');
    }
  }

  return (
    <Layout>
      {start === 0 && (
        <div className="relative flex justify-center items-center py-12 mb-6">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <div className="w-[100px] h-[100px] bg-[#CDEDEC] rounded-full" />
          </div>
          <h1 className="relative text-2xl font-bold text-center">
            まずは{total}問の性格診断から！
          </h1>
        </div>
      )}

      <Progress current={answeredCount} total={total} />

      <hr className="border-t border-[#2B3541] my-4" />

      <ol className="space-y-6 mt-4">
        {visible.map(q => (
          <li key={q.question_uuid} className="text-center border-b border-[#2B3541] pb-2">
            <p className="text-base mb-3">{q.question_body}</p>

            <div className="flex justify-center gap-5 px-4">
              {[1, 2, 3, 4, 5].map(n => (
                <button
                  key={n}
                  aria-label={`選択肢 ${n}`}
                  onClick={() => handleSelect(q.question_uuid, n)}
                  className={
                    answers[q.question_uuid] === n
                      ? `${btnBase} bg-[#00A8A5]`
                      : `${btnBase} bg-white hover:bg-gray-200`
                  }
                />
              ))}
            </div>

            <div className="flex justify-between gap-6 px-4 mt-2 -mx-3 text-sm text-gray-600">
              <span>当てはまらない</span>
              <span>当てはまる</span>
            </div>
          </li>
        ))}
      </ol>

      <div className="flex justify-start mt-6">
        {start > 0 && (
          <Button
            onClick={handlePrev}
            className="border-[#2B3541] bg-white text-[#2B3541]"
          >
            前の5問へ
          </Button>
        )}
      </div>

      <div className="flex justify-center mt-8">
        <Button
          onClick={handleFinish}
          className="bg-[#00A8A5] text-white hover:bg-[#01908d] !rounded-full border-[#00A8A5]"
        >
          結果を見る
        </Button>
      </div>
    </Layout>
  );
}