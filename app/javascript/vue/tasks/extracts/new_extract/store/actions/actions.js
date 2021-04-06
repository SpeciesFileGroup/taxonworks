import ActionNames from './actionNames'

import loadProjectPreferences from './loadProjectPreferences'
import loadUserPreferences from './loadUserPreferences'
import saveExtract from './saveExtract'
import saveOriginRelationship from './saveOriginRelationships'

const ActionFunctions = {
  [ActionNames.LoadProjectPreferences]: loadProjectPreferences,
  [ActionNames.LoadUserPreferences]: loadUserPreferences,
  [ActionNames.SaveExtract]: saveExtract,
  [ActionNames.SaveOriginRelationship]: saveOriginRelationship
}

export {
  ActionNames,
  ActionFunctions
}
