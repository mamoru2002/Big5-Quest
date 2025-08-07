// frontend/src/api/index.js
import axios from 'axios';

// Rails 側と cookie 連携するなら withCredentials: true を設定
const client = axios.create({
  baseURL: 'http://localhost:3000/api',
  withCredentials: true,
});

export async function fetchQuestions(formName) {
  // GET /api/diagnosis_forms/:name/questions
  const res = await client.get(`/diagnosis_forms/${formName}/questions`);
  return res.data;  // すでに JSON 配列になっているはず
}