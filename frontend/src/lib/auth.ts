import api, { setAuthToken } from './api';

type AuthRes = { token: string };

export async function signup(email: string, password: string): Promise<string> {
  const res = await api.post<AuthRes>('/api/auth/signup', { email, password });
  const token = res.data.token;
  setAuthToken(token);
  return token;
}

export async function login(email: string, password: string): Promise<string> {
  const res = await api.post<AuthRes>('/api/auth/login', { email, password });
  const token = res.data.token;
  setAuthToken(token);
  return token;
}
