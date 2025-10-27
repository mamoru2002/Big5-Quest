import api, { setAuthToken, clearAuthToken, getAuthToken } from './api';

export type SignUpParams = {
  nickname?: string;
  email: string;
  password: string;
};

export const AuthAPI = {
  async guestLogin(): Promise<{ form_name: string; result_id: number } | null> {
    const res = await api.post('/auth/guest_login');
    const authHeader = ((res.headers as any)?.['authorization'] as string) || '';
    const headerToken = authHeader.replace(/^Bearer\s+/i, '');
    const bodyToken   = res.data?.token as string | undefined;
    const token = headerToken || bodyToken || '';
    if (token) {
      setAuthToken(token);
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
    return res.data?.next_diagnosis ?? null;
  },
  async login(email: string, password: string) {
    const { data, headers } = await api.post('/login', { email, password });
    const token = ((headers as any)?.['authorization'] as string)?.replace(/^Bearer\s+/i, '') || data?.token;
    if (token) {
      setAuthToken(token);
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
    return data;
  },
  async signUp({ nickname, email, password }: SignUpParams) {
    const payload = {
      nickname,
      email,
      password,
      password_confirmation: password,
    };
    const { data, headers } = await api.post('/sign_up', payload);
    const token = ((headers as any)?.['authorization'] as string)?.replace(/^Bearer\s+/i, '') || data?.token;
    if (token) {
      setAuthToken(token);
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
    return data;
  },

  async me() {
    const { data } = await api.get('/me');
    return data;
  },

  async logout() {
    try {
      await api.delete('/logout');
    } finally {
      clearAuthToken();
      delete api.defaults.headers.common['Authorization'];
    }
  },
};

export async function ensureAuth(): Promise<void> {
  if (!getAuthToken()) {
    await AuthAPI.guestLogin();
  }
}

export async function signup(params: SignUpParams) {
  return AuthAPI.signUp(params);
}
export async function login(email: string, password: string) {
  return AuthAPI.login(email, password);
}