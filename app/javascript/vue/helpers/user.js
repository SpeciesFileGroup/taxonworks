import { ATTR_CURRENT_USER_ID } from 'constants/index.js'

export const getCurrentUserId = () => document
  .querySelector(`[${ATTR_CURRENT_USER_ID}]`)
  .getAttribute(ATTR_CURRENT_USER_ID)
