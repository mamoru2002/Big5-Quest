import api from "../lib/api";

export async function fetchQuestions(formName) {
  const { data } = await api.get(`/diagnosis_forms/${encodeURIComponent(formName)}/questions`);
  return data;
}

export async function startDiagnosis(formName) {
  const { data } = await api.post('/diagnosis_results', {
    diagnosis_result: { form_name: formName },
  });
  return data.id;
}

export async function submitAnswers(resultId, answers) {
  await api.post(`/diagnosis_results/${encodeURIComponent(resultId)}/answers`, { answers });
}

export async function completeDiagnosis(resultId) {
  const { data } = await api.post(`/diagnosis_results/${encodeURIComponent(resultId)}/complete`);
  return data.scores;
}

export async function fetchResultScores(id) {
  const { data } = await api.get(`/diagnosis_results/${encodeURIComponent(id)}`);
  return data.scores;
}

export async function fetchChallengesByTrait(code) {
  const { data } = await api.get(`/traits/${encodeURIComponent(code)}/challenges`);
  return data;
}

export const fetchChallenges = fetchChallengesByTrait;

export async function createUserChallenges(diagnosisResultId, challengeIds) {
  await api.post('/user_challenges', {
    diagnosis_result_id: diagnosisResultId,
    challenge_ids: challengeIds,
  });
}

export async function fetchCurrentWeek() {
  const { data } = await api.get('/weeks/current');
  return data;
}

export async function fetchWeek(offset) {
  const { data } = await api.get(`/weeks/${encodeURIComponent(offset)}`);
  return data;
}

export async function updateUserChallenge(id, payload) {
  const { data } = await api.patch(`/user_challenges/${encodeURIComponent(id)}`, {
    user_challenge: payload,
  });
  return data;
}

export async function fetchEmotionTags() {
  const { data } = await api.get('/emotion_tags');
  return data;
}

export { default as api } from "../lib/api";
