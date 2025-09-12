import api, { setVisitToken, getVisitToken } from './api';

export async function ensureVisitToken(): Promise<string> {
  const existing = getVisitToken();
  if (existing) return existing;
  const res = await api.post('/api/visits');
  const token = String((res.data as any).visit_token);
  setVisitToken(token);
  return token;
}
