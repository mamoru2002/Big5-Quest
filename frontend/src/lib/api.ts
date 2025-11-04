import axios, { AxiosInstance, AxiosHeaders } from 'axios';

const AUTH_TOKEN_KEY  = 'jwt';
const VISIT_TOKEN_KEY = 'visit_token';
const GUEST_TOKEN_KEY = 'guest_login';

export function getAuthToken(): string | null { return localStorage.getItem(AUTH_TOKEN_KEY); }
export function setAuthToken(t: string): void { localStorage.setItem(AUTH_TOKEN_KEY, t); }
export function clearAuthToken(): void { localStorage.removeItem(AUTH_TOKEN_KEY); }

export function getVisitToken(): string | null { return localStorage.getItem(VISIT_TOKEN_KEY); }
export function setVisitToken(t: string): void { localStorage.setItem(VISIT_TOKEN_KEY, t); }
export function clearVisitToken(): void { localStorage.removeItem(VISIT_TOKEN_KEY); }

export function markGuestSession(): void { localStorage.setItem(GUEST_TOKEN_KEY, '1'); }
export function clearGuestSession(): void { localStorage.removeItem(GUEST_TOKEN_KEY); }
export function isGuestSession(): boolean { return localStorage.getItem(GUEST_TOKEN_KEY) === '1'; }

const DEFAULT_BASE = 'https://api.big5-quest.com/api';
const baseURL = (import.meta.env.VITE_API_BASE_URL || DEFAULT_BASE).replace(/\/+$/, '');

const api: AxiosInstance = axios.create({
  baseURL,
  withCredentials: false,
  headers: { 'Content-Type': 'application/json' },
  validateStatus: (status) => {
    return (status >= 200 && status < 300) || status === 304
  },
});

api.interceptors.request.use((config) => {
  if (!config.headers || !(config.headers as any).set) {
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
    const authHeader = ((res.headers as any)?.['authorization'] as string) || '';
    const headerToken = authHeader.replace(/^Bearer\s+/i, '');
    const bodyToken =
      res.data && typeof res.data === 'object' && 'token' in res.data
        ? (res.data as any).token as string
        : '';
    const token = headerToken || bodyToken;
    if (token) {
      setAuthToken(token);
      (api.defaults.headers as any).common['Authorization'] = `Bearer ${token}`;
    }

    const visitHeader = ((res.headers as any)?.['x-visit-token'] as string) || '';
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
    const data   = err.response?.data;

    if (status === 401) {
      clearAuthToken();
      clearGuestSession();
    } else if (
      status === 403 &&
      (data?.error === 'diagnosis_required' || data?.error === 'previous_week_missed')
    ) {
      if (window.location.pathname !== '/diagnosis' && window.location.pathname !== '/mypage') {
        window.location.assign('/diagnosis');
      }
    }

    return Promise.reject(err);
  }
);

export const DiagnosisAPI = {
  questions(formName: string) {
    if (!formName) throw new Error('formName is required');
    return api.get(`/diagnosis_forms/${encodeURIComponent(formName)}/questions`,
    { headers: { 'Cache-Control': 'no-cache' } }).then(r => r.data);
  },

  createResult(diagnosis_form_id: number) {
    if (!diagnosis_form_id) throw new Error('diagnosis_form_id is required');
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

export default api;