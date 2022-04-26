import ActionNames from './actionNames'

import removeExtract from './removeExtract'
import loadExtract from './LoadExtract'
import loadIdentifiers from './loadIdentifiers'
import loadRecents from './LoadRecents'
import loadProjectPreferences from './loadProjectPreferences'
import loadProtocols from './loadProtocols'
import loadUserPreferences from './loadUserPreferences'
import loadOriginRelationship from './loadOriginRelationship'
import saveExtract from './saveExtract'
import saveIdentifiers from './saveIdentifiers'
import saveOriginRelationship from './saveOriginRelationships'
import saveProtocols from './saveProtocols'
import resetState from './resetState'
import removeOriginRelationship from './removeOriginRelationship'

const ActionFunctions = {
  [ActionNames.LoadExtract]: loadExtract,
  [ActionNames.LoadIdentifiers]: loadIdentifiers,
  [ActionNames.RemoveExtract]: removeExtract,
  [ActionNames.LoadRecents]: loadRecents,
  [ActionNames.LoadProjectPreferences]: loadProjectPreferences,
  [ActionNames.LoadUserPreferences]: loadUserPreferences,
  [ActionNames.LoadOriginRelationship]: loadOriginRelationship,
  [ActionNames.LoadProtocols]: loadProtocols,
  [ActionNames.SaveExtract]: saveExtract,
  [ActionNames.SaveIdentifiers]: saveIdentifiers,
  [ActionNames.SaveOriginRelationship]: saveOriginRelationship,
  [ActionNames.SaveProtocols]: saveProtocols,
  [ActionNames.RemoveOriginRelationship]: removeOriginRelationship,
  [ActionNames.ResetState]: resetState
}

export {
  ActionNames,
  ActionFunctions
}
