import api from '../lib/api';

export async function fetchProfile() {
  const { data } = await api.get('/profile');
  return data;
}

export async function saveProfile(payload) {
  const { data } = await api.patch('/profile', { profile: payload });
  return data;
}