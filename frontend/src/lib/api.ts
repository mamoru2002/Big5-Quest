import axios, { AxiosInstance, AxiosHeaders } from 'axios';

const AUTH_TOKEN_KEY = 'jwt';
const VISIT_TOKEN_KEY = 'visit_token';

export function getAuthToken(): string | null { return localStorage.getItem(AUTH_TOKEN_KEY); }
export function setAuthToken(t: string): void { localStorage.setItem(AUTH_TOKEN_KEY, t); }
export function clearAuthToken(): void { localStorage.removeItem(AUTH_TOKEN_KEY); }

export function getVisitToken(): string | null { return localStorage.getItem(VISIT_TOKEN_KEY); }
export function setVisitToken(t: string): void { localStorage.setItem(VISIT_TOKEN_KEY, t); }
export function clearVisitToken(): void { localStorage.removeItem(VISIT_TOKEN_KEY); }

const DEFAULT_BASE = 'https://api.big5-quest.com/api';
const baseURL = (import.meta.env.VITE_API_BASE_URL || DEFAULT_BASE).replace(/\/+$/, '');

const api: AxiosInstance = axios.create({
  baseURL,
  withCredentials: false,
  headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
  // Axios v1系は AxiosHeaders を使うと型エラーが出にくい
  if (!config.headers || !(config.headers as any).set) {
    // どちらでも可：new AxiosHeaders(...) でも OK
    config.headers = AxiosHeaders.from(config.headers);
  }
  const headers = config.headers as AxiosHeaders;

  const jwt = getAuthToken();
  if (jwt) headers.set('Authorization', `Bearer ${jwt}`);

  const vt = getVisitToken();
  if (vt) headers.set('X-Visit-Token', vt);

  return config;
});

api.interceptors.response.use(
  (res) => {
    // JWT をヘッダ or 本文から拾って保存
    const authHeader = (res.headers?.['authorization'] as string) || '';
    const headerToken = authHeader.replace(/^Bearer\s+/i, '');
    const bodyToken =
      res.data && typeof res.data === 'object' && 'token' in res.data
        ? (res.data as any).token as string
        : '';
    const token = headerToken || bodyToken;
    if (token) setAuthToken(token);

    // Visit Token も保存
    const visitHeader = (res.headers?.['x-visit-token'] as string) || '';
    const bodyVisit =
      res.data && typeof res.data === 'object' && 'visit_token' in res.data
        ? (res.data as any).visit_token as string
        : '';
    const vt = visitHeader || bodyVisit;
    if (vt) setVisitToken(vt);

    return res;
  },
  (err) => {
    const status = err.response?.status;
    const data = err.response?.data;

    if (status === 401) {
      clearAuthToken();
      // ここでログイン画面へ飛ばす等（任意）
    } else if (
      status === 403 &&
      (data?.error === 'diagnosis_required' || data?.error === 'previous_week_missed')
    ) {
      // 診断に誘導（任意）
    }
    return Promise.reject(err);
  }
);

// APIラッパ
export const AuthAPI = {
  async guestLogin() {
    const { data } = await api.post('/auth/guest_login');
    if (data?.token) setAuthToken(data.token);
    return data; // { token, user: {...} }
  },
  async login(email: string, password: string) {
    const { data } = await api.post('/login', { email, password });
    if (data?.token) setAuthToken(data.token);
    return data;
  },
  async me() {
    const { data } = await api.get('/me');
    return data;
  },
  async logout() {
    try { await api.delete('/logout'); } finally { clearAuthToken(); }
  },
};

export const DiagnosisAPI = {
  questions(formName = 'full_50') {
    return api.get(`/diagnosis_forms/${encodeURIComponent(formName)}/questions`).then(r => r.data);
  },
  createResult(diagnosis_form_id: number) {
    return api.post('/diagnosis_results', { diagnosis_form_id }).then(r => r.data);
  },
  updateResponses(resultId: number, responses: Array<{ question_uuid: string; value: number }>) {
    return api.put(`/diagnosis_results/${resultId}/responses`, { responses }).then(r => r.data);
  },
  complete(resultId: number) {
    return api.post(`/diagnosis_results/${resultId}/complete`).then(r => r.data);
  },
};

export const WeeksAPI = {
  current() { return api.get('/weeks/current').then(r => r.data); },
  show(offset: number) { return api.get(`/weeks/${offset}`).then(r => r.data); },
};

// ★未認証ならゲストログインしてトークン確保
export async function ensureAuth(): Promise<void> {
  if (!getAuthToken()) {
    await AuthAPI.guestLogin();
  }
}
export default api;