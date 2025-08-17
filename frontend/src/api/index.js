import axios from 'axios';

const client = axios.create({
  baseURL: 'http://localhost:3000/api',
  withCredentials: true,
});

export async function fetchQuestions(formName) {
  const res = await client.get(`/diagnosis_forms/${formName}/questions`);
  return res.data;
}

export async function startDiagnosis(formName) {
  const payload = { diagnosis_result: { form_name: formName } };
  const res = await client.post('/diagnosis_results', payload);
  return res.data.id;
}

export async function submitAnswers(resultId, answers) {
  await client.post(`/diagnosis_results/${resultId}/answers`, { answers });
}

export async function completeDiagnosis(resultId) {
  const res = await client.post(`/diagnosis_results/${resultId}/complete`);
  return res.data.scores;
}

export async function fetchResultScores(id) {
  const res = await client.get(`/diagnosis_results/${id}`);
  return res.data.scores;
}

export async function fetchChallengesByTrait(code) {
  const res = await client.get(`/traits/${code}/challenges`);
  return res.data;
}

export async function createUserChallenges(diagnosisResultId, challengeIds) {
  await client.post('/user_challenges', {
    diagnosis_result_id: diagnosisResultId,
    challenge_ids: challengeIds,
  });
}

export async function fetchChallenges(code) {
  const res = await client.get(`/traits/${code}/challenges`);
  return res.data;
}

export async function fetchCurrentWeek() {
  const res = await client.get('/weeks/current');
  return res.data;
}

export async function fetchWeek(offset) {
  const res = await client.get('/weeks/show', { params: { offset } });
  return res.data;
}

export async function updateUserChallenge(id, payload) {
  const res = await client.patch(`/user_challenges/${id}`, {
    user_challenge: payload,
  });
  return res.data;
}

export async function fetchEmotionTags() {
  const res = await client.get('/emotion_tags');
  return res.data;
}