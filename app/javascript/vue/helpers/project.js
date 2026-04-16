import {
  ATTR_CURRENT_PROJECT_ID,
  ATTR_CURRENT_PROJECT_TOKEN
} from '@/constants/index.js'

export function getCurrentProjectId() {
  return document
    .querySelector(`[${ATTR_CURRENT_PROJECT_ID}]`)
    ?.getAttribute(ATTR_CURRENT_PROJECT_ID)
}

export function getCurrentProjectToken() {
  return document
    .querySelector(`[${ATTR_CURRENT_PROJECT_TOKEN}]`)
    ?.getAttribute(ATTR_CURRENT_PROJECT_TOKEN)
}
