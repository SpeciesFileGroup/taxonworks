import ActionNames from './actionNames'

import loadProjectPreferences from './loadProjectPreferences'
import loadUserPreferences from './loadUserPreferences'
import saveExtract from './saveExtract'
import saveOriginRelationship from './saveOriginRelationships'
import resetState from './resetState'

const ActionFunctions = {
  [ActionNames.LoadProjectPreferences]: loadProjectPreferences,
  [ActionNames.LoadUserPreferences]: loadUserPreferences,
  [ActionNames.SaveExtract]: saveExtract,
  [ActionNames.SaveOriginRelationship]: saveOriginRelationship,
  [ActionNames.ResetState]: resetState
}

export {
  ActionNames,
  ActionFunctions
}
