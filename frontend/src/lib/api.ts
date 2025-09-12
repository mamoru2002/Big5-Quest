import axios, { AxiosInstance, AxiosHeaders } from 'axios';

const AUTH_TOKEN_KEY = 'jwt';
const VISIT_TOKEN_KEY = 'visit_token';

export function getAuthToken(): string | null { return typeof localStorage !== 'undefined' ? localStorage.getItem(AUTH_TOKEN_KEY) : null; }
export function setAuthToken(t: string): void { if (typeof localStorage !== 'undefined') localStorage.setItem(AUTH_TOKEN_KEY, t); }
export function clearAuthToken(): void { if (typeof localStorage !== 'undefined') localStorage.removeItem(AUTH_TOKEN_KEY); }

export function getVisitToken(): string | null { return typeof localStorage !== 'undefined' ? localStorage.getItem(VISIT_TOKEN_KEY) : null; }
export function setVisitToken(t: string): void { if (typeof localStorage !== 'undefined') localStorage.setItem(VISIT_TOKEN_KEY, t); }

// デフォルトは本番の API エンドポイント（/api 付き）
const DEFAULT_BASE = 'https://api.big5-quest.com/api';
// .env / 環境変数で上書き可（末尾スラッシュは除去）
const baseURL = (import.meta?.env?.VITE_API_BASE_URL || DEFAULT_BASE).replace(/\/+$/, '');

const api: AxiosInstance = axios.create({
  baseURL,
  withCredentials: false,
  headers: { 'Content-Type': 'application/json' },
});

// 認証トークン / 訪問トークンをヘッダに付与（型安全に）
api.interceptors.request.use((config) => {
  const headers = AxiosHeaders.from(config.headers);

  const jwt = getAuthToken();
  if (jwt) headers.set('Authorization', `Bearer ${jwt}`);

  const vt = getVisitToken();
  if (vt) headers.set('X-Visit-Token', vt);

  config.headers = headers;
  return config;
});

export { api };
export default api;
