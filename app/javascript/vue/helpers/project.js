import { ATTR_CURRENT_PROJECT_ID } from 'constants/index.js'

export const getCurrentProjectId = () =>
  document
    .querySelector(`[${ATTR_CURRENT_PROJECT_ID}]`)
    .getAttribute(ATTR_CURRENT_PROJECT_ID)
