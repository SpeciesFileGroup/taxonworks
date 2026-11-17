import { Session } from '@/routes/endpoints/Session'
import {
  SESSION_EXPIRED_REASON,
  elapsedSinceAlive,
  markExpired,
  onCheckRequested,
  sessionStatus,
  touchSession
} from '@/utils/SessionStatus'

const MINUTE = 60 * 1000

const PING_INTERVAL = 60 * MINUTE

const TICK = 1000

const RETRY_DELAYS = [MINUTE, 2 * MINUTE, 5 * MINUTE, PING_INTERVAL]

let inFlight
let tickId
let unsubscribeCheck
let lastFailureAt = 0
let failureCount = 0

function retryDelay() {
  return RETRY_DELAYS[Math.min(failureCount - 1, RETRY_DELAYS.length - 1)]
}

function isDue() {
  if (elapsedSinceAlive() < PING_INTERVAL) return false

  if (failureCount && Date.now() - lastFailureAt < retryDelay()) return false

  return true
}

function ping({ onUnverified } = {}) {
  if (!inFlight) {
    inFlight = Session.status()
      .then(({ body }) => {
        failureCount = 0

        if (!body.signed_in) {
          markExpired(SESSION_EXPIRED_REASON.SignedOut)
        } else if (!body.project_selected) {
          markExpired(SESSION_EXPIRED_REASON.ProjectLost)
        } else {
          touchSession()
        }
      })
      .catch(() => {
        failureCount += 1
        lastFailureAt = Date.now()
      })
      .finally(() => {
        inFlight = undefined
      })
  }

  return inFlight.then(() => {
    if (!sessionStatus.isExpired) onUnverified?.()
  })
}

function check(options) {
  if (sessionStatus.isExpired) return
  if (!options?.force && !isDue()) return

  ping(options)
}

function handleTick() {
  check()
}

export function startSessionKeepalive() {
  if (tickId) return

  touchSession()

  tickId = setInterval(handleTick, TICK)

  unsubscribeCheck = onCheckRequested(({ onUnverified }) => {
    check({ force: true, onUnverified })
  })
}

export function stopSessionKeepalive() {
  clearInterval(tickId)
  tickId = undefined

  unsubscribeCheck?.()
  unsubscribeCheck = undefined
}
