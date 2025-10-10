import api, { setAuthToken, clearAuthToken } from './api'

export type SignUpParams = {
  nickname?: string
  email: string
  password: string
}

export const AuthAPI = {
  async guestLogin() {
    const { data } = await api.post('/auth/guest_login')
    if (data?.token) setAuthToken(data.token)
    return data
  },
  async login(email: string, password: string) {
    const { data } = await api.post('/login', { email, password })
    if (data?.token) setAuthToken(data.token)
    return data
  },
  async signUp({ nickname, email, password }: SignUpParams) {
    const payload = {
      nickname, // バックエンドが無視してもOK
      email,
      password,
      password_confirmation: password,
    }
    const { data } = await api.post('/sign_up', payload)
    if (data?.token) setAuthToken(data.token)
    return data
  },
  async me() {
    const { data } = await api.get('/me')
    return data
  },
  async logout() {
    try {
      await api.delete('/logout')
    } finally {
      clearAuthToken()
    }
  },
}

export async function signup(params: SignUpParams) {
  return AuthAPI.signUp(params)
}
export async function login(email: string, password: string) {
  return AuthAPI.login(email, password)
}