const REDIRECT_KEY_PREFIX = 'weekly_redirect_done'
const SKIP_SCHEDULE_PREFIX = 'weekly_skip_scheduled'

function toISODateString(date) {
  if (!(date instanceof Date) || Number.isNaN(date.getTime())) return null
  return date.toISOString().split('T')[0]
}

function parseWeekStart(startAt) {
  if (!startAt) return null
  try {
    if (typeof startAt === 'string' && /^\d{4}-\d{2}-\d{2}/.test(startAt)) {
      return new Date(`${startAt}T00:00:00Z`)
    }
    const parsed = new Date(startAt)
    if (Number.isNaN(parsed.getTime())) return null
    return parsed
  } catch (e) {
    console.debug('parseWeekStart error', e)
    return null
  }
}

export function buildWeekKey(startAt) {
  const parsed = parseWeekStart(startAt)
  if (!parsed) return null
  return toISODateString(parsed)
}

function storageAvailable() {
  try {
    return typeof window !== 'undefined' && !!window.localStorage
  } catch (e) {
    console.debug('localStorage unavailable', e)
    return false
  }
}

function redirectKey(userId, weekKey) {
  return `${REDIRECT_KEY_PREFIX}:${userId}:${weekKey}`
}

function skipKey(userId, weekKey) {
  return `${SKIP_SCHEDULE_PREFIX}:${userId}:${weekKey}`
}

export function hasRedirectedForWeek(userId, weekKey) {
  if (!userId || !weekKey || !storageAvailable()) return false
  try {
    return window.localStorage.getItem(redirectKey(userId, weekKey)) === '1'
  } catch (e) {
    console.debug('hasRedirectedForWeek error', e)
    return false
  }
}

export function markRedirectedForWeek(userId, weekKey) {
  if (!userId || !weekKey || !storageAvailable()) return
  try {
    window.localStorage.setItem(redirectKey(userId, weekKey), '1')
  } catch (e) {
    console.debug('markRedirectedForWeek error', e)
  }
}

export function markScheduledSkip(userId, weekKey, active) {
  if (!userId || !weekKey || !storageAvailable()) return
  try {
    if (active) {
      window.localStorage.setItem(skipKey(userId, weekKey), '1')
    } else {
      window.localStorage.removeItem(skipKey(userId, weekKey))
    }
  } catch (e) {
    console.debug('markScheduledSkip error', e)
  }
}

export function isWeekScheduledToSkip(userId, weekKey) {
  if (!userId || !weekKey || !storageAvailable()) return false
  try {
    return window.localStorage.getItem(skipKey(userId, weekKey)) === '1'
  } catch (e) {
    console.debug('isWeekScheduledToSkip error', e)
    return false
  }
}

export function computeNextWeekKey(startAt) {
  const parsed = parseWeekStart(startAt)
  if (!parsed) return null
  const next = new Date(parsed.getTime())
  next.setUTCDate(next.getUTCDate() + 7)
  return toISODateString(next)
}
