// frontend/src/api/index.js
import axios from 'axios';

const client = axios.create({
  baseURL: 'http://localhost:3000/api',
  withCredentials: true,
});

/** 質問一覧取得 */
export async function fetchQuestions(formName) {
  const res = await client.get(`/diagnosis_forms/${formName}/questions`);
  return res.data;
}

/** 診断開始 */
export async function startDiagnosis(formName) {
  const payload = { diagnosis_result: { form_name: formName } };
  const res = await client.post('/diagnosis_results', payload);
  return res.data.id;
}

/** 回答送信 */
export async function submitAnswers(resultId, answers) {
  await client.post(`/diagnosis_results/${resultId}/answers`, { answers });
}

/** 診断完了 */
export async function completeDiagnosis(resultId) {
  const res = await client.post(`/diagnosis_results/${resultId}/complete`);
  return res.data.scores;
}

/** 診断結果のスコア取得 */
export async function fetchResultScores(id) {
  const res = await client.get(`/diagnosis_results/${id}`);
  return res.data.scores;
}

// 特性ごとのチャレンジ一覧
export async function fetchChallengesByTrait(code) {
  const res = await client.get(`/traits/${code}/challenges`);
  return res.data; // [{id, title, difficulty}, ...]
}

// チャレンジ登録（1〜4件）
export async function createUserChallenges(diagnosisResultId, challengeIds) {
  await client.post('/user_challenges', {
    diagnosis_result_id: diagnosisResultId,
    challenge_ids: challengeIds,
  });
}