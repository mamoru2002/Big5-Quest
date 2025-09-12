import axios, { AxiosInstance } from 'axios';

const AUTH_TOKEN_KEY = 'jwt';
const VISIT_TOKEN_KEY = 'visit_token';

export function getAuthToken(): string | null { return localStorage.getItem(AUTH_TOKEN_KEY); }
export function setAuthToken(t: string): void { localStorage.setItem(AUTH_TOKEN_KEY, t); }
export function clearAuthToken(): void { localStorage.removeItem(AUTH_TOKEN_KEY); }

export function getVisitToken(): string | null { return localStorage.getItem(VISIT_TOKEN_KEY); }
export function setVisitToken(t: string): void { localStorage.setItem(VISIT_TOKEN_KEY, t); }

const api: AxiosInstance = axios.create({
  baseURL: 'https://api.big5-quest.com',
  withCredentials: false,
  headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
  const jwt = getAuthToken();
  if (jwt) { (config.headers = config.headers || {}); (config.headers as any)['Authorization'] = `Bearer ${jwt}`; }
  const vt = getVisitToken();
  if (vt) { (config.headers = config.headers || {}); (config.headers as any)['X-Visit-Token'] = vt; }
  return config;
});

export default api;
