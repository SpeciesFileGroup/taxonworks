import ActionNames from './actionNames'

import loadProjectPreferences from './loadProjectPreferences'
import loadUserPreferences from './loadUserPreferences'
import saveExtract from './saveExtract'

const ActionFunctions = {
  [ActionNames.LoadProjectPreferences]: loadProjectPreferences,
  [ActionNames.LoadUserPreferences]: loadUserPreferences,
  [ActionNames.SaveExtract]: saveExtract
}

export {
  ActionNames,
  ActionFunctions
}
