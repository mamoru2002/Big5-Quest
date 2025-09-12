import axios, { AxiosInstance, RawAxiosRequestHeaders } from 'axios';

const AUTH_TOKEN_KEY = 'jwt';
const VISIT_TOKEN_KEY = 'visit_token';

export function getAuthToken(): string | null { return localStorage.getItem(AUTH_TOKEN_KEY); }
export function setAuthToken(t: string): void { localStorage.setItem(AUTH_TOKEN_KEY, t); }
export function clearAuthToken(): void { localStorage.removeItem(AUTH_TOKEN_KEY); }

export function getVisitToken(): string | null { return localStorage.getItem(VISIT_TOKEN_KEY); }
export function setVisitToken(t: string): void { localStorage.setItem(VISIT_TOKEN_KEY, t); }

const DEFAULT_BASE = 'https://api.big5-quest.com/api';
const baseURL = (import.meta.env.VITE_API_BASE_URL || DEFAULT_BASE).replace(/\/+$/, '');

const api: AxiosInstance = axios.create({
  baseURL,
  withCredentials: false,
  headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
  const headers = (config.headers ||= {} as RawAxiosRequestHeaders);

  const jwt = getAuthToken();
  if (jwt) headers['Authorization'] = `Bearer ${jwt}`;

  const vt = getVisitToken();
  if (vt) headers['X-Visit-Token'] = vt;

  return config;
});

export default api;