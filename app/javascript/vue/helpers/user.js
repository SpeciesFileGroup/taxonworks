import { ATTR_CURRENT_USER_ID } from '@/constants/index.js'

export function getCurrentUserId() {
  return document
    .querySelector(`[${ATTR_CURRENT_USER_ID}]`)
    .getAttribute(ATTR_CURRENT_USER_ID)
}

export function getCSRFToken() {
  return document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
}
