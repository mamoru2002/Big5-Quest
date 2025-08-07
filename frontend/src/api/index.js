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

/** 回答一括送信 */
export async function submitAnswers(resultId, answers) {
  await client.post(`/diagnosis_results/${resultId}/answers`, { answers });
}

/** 診断完了 */
export async function completeDiagnosis(resultId) {
  const res = await client.post(`/diagnosis_results/${resultId}/complete`);
  return res.data.scores;
}