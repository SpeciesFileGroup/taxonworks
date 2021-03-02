import ActionNames from './actionNames'

import loadProjectPreferences from './loadProjectPreferences'
import loadUserPreferences from './loadUserPreferences'

const ActionFunctions = {
  [ActionNames.LoadProjectPreferences]: loadProjectPreferences,
  [ActionNames.LoadUserPreferences]: loadUserPreferences
}

export {
  ActionNames,
  ActionFunctions
}
