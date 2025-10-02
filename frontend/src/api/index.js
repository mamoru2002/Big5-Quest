import api from '../lib/api';

/** 質問フォームの設問取得 */
export async function fetchQuestions(formName) {
  const { data } = await api.get(`/diagnosis_forms/${encodeURIComponent(formName)}/questions`);
  return data;
}

/** 診断開始（結果IDを返す） */
export async function startDiagnosis(formName) {
  const { data } = await api.post('/diagnosis_results', {
    diagnosis_result: { form_name: formName },
  });
  return data.id;
}

/** 回答送信 */
export async function submitAnswers(resultId, answers) {
  await api.put(`/diagnosis_results/${encodeURIComponent(resultId)}/responses`, { responses: answers });
}

/** 診断完了（スコアを返す） */
export async function completeDiagnosis(resultId) {
  const { data } = await api.post(`/diagnosis_results/${encodeURIComponent(resultId)}/complete`);
  return data.scores;
}

/** 診断結果のスコア取得 */
export async function fetchResultScores(id) {
  const { data } = await api.get(`/diagnosis_results/${encodeURIComponent(id)}`);
  return data.scores;
}

/** 特性コード別のチャレンジ一覧 */
export async function fetchChallengesByTrait(code) {
  const { data } = await api.get(`/traits/${encodeURIComponent(code)}/challenges`);
  return data;
}

export const fetchChallenges = fetchChallengesByTrait;

/** ユーザーのチャレンジ確定 */
export async function createUserChallenges(diagnosisResultId, challengeIds) {
  await api.post('/user_challenges', {
    diagnosis_result_id: diagnosisResultId,
    challenge_ids: challengeIds,
  });
}

/** 今週情報 */
export async function fetchCurrentWeek() {
  const { data } = await api.get('/weeks/current');
  return data;
}

/** 週オフセット指定の週情報 */
export async function fetchWeek(offset) {
  const { data } = await api.get(`/weeks/${encodeURIComponent(offset)}`);
  return data;
}

/** ユーザーチャレンジ更新 */
export async function updateUserChallenge(id, payload) {
  const { data } = await api.patch(`/user_challenges/${encodeURIComponent(id)}`, {
    user_challenge: payload,
  });
  return data;
}

/** 感情タグ一覧 */
export async function fetchEmotionTags() {
  const { data } = await api.get('/emotion_tags');
  return data;
}

/** 互換用：api インスタンスも名前付き＋デフォルトでエクスポート */
export { api };
export default api;
