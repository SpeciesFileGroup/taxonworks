import {
  ATTR_CURRENT_USER_ID,
  ATTR_CURRENT_USER_IS_ADMINISTRATOR
} from '@/constants/index.js'

export function getCurrentUserId() {
  return document
    .querySelector(`[${ATTR_CURRENT_USER_ID}]`)
    .getAttribute(ATTR_CURRENT_USER_ID)
}

export function isCurrentUserAdministrator() {
  const el = document.querySelector(`[${ATTR_CURRENT_USER_IS_ADMINISTRATOR}]`)

  return el?.getAttribute(ATTR_CURRENT_USER_IS_ADMINISTRATOR) === 'true'
}

export function getCSRFToken() {
  return document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
}
