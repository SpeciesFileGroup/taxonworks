import { reactive, readonly } from 'vue'
import { EventEmitter } from '@/utils/EventEmitter'

export const SESSION_EXPIRED_REASON = {
  ProjectLost: 'PROJECT_LOST',
  SignedOut: 'SIGNED_OUT'
}

const STORAGE_KEY = 'tw:session:lastAliveAt'

const state = reactive({
  isExpired: false,
  reason: null
})

const emitter = new EventEmitter()

let lastAliveAt = 0
let checkListenerCount = 0

function readLastAliveAt() {
  try {
    return Number(window.localStorage.getItem(STORAGE_KEY)) || 0
  } catch {
    return lastAliveAt
  }
}

export function elapsedSinceAlive() {
  const difference = Date.now() - readLastAliveAt()

  return difference < 0 ? Infinity : difference
}

export function touchSession() {
  lastAliveAt = Date.now()

  try {
    window.localStorage.setItem(STORAGE_KEY, String(lastAliveAt))
  } catch {}
}

export function markExpired(reason) {
  state.isExpired = true
  state.reason = reason
}

export function requestCheck(onUnverified) {
  if (!checkListenerCount) {
    onUnverified?.()
    return
  }

  emitter.emit('check', { onUnverified })
}

export function onCheckRequested(listener) {
  checkListenerCount += 1

  emitter.on('check', listener)

  return () => {
    checkListenerCount -= 1

    emitter.removeListener('check', listener)
  }
}

export const sessionStatus = readonly(state)
