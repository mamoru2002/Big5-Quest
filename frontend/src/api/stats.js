import api from '../lib/api'

export async function fetchMe() {
  const { data } = await api.get('/me')
  return data
}

export async function fetchStatsSummary() {
  const { data } = await api.get('/stats/summary')
  return data
}

export async function fetchTraitHistory(code = 'C') {
  const { data } = await api.get('/stats/trait_history', { params: { code } })
  return data
}

export async function fetchWeekSkipStatus() {
  const { data } = await api.get('/week_skips/status')
  return data
}

export async function updateWeekSkip(skip) {
  const { data } = await api.patch('/week_skips', { skip })
  return data
}