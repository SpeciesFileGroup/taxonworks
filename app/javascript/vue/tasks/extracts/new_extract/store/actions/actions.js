import ActionNames from './actionNames'

import loadConfidences from './loadConfidences'
import loadExtract from './LoadExtract'
import loadIdentifiers from './loadIdentifiers'
import loadOriginRelationship from './loadOriginRelationship'
import loadProjectPreferences from './loadProjectPreferences'
import loadProtocols from './loadProtocols'
import loadRecents from './LoadRecents'
import loadUserPreferences from './loadUserPreferences'
import removeConfidence from './removeConfidence'
import removeExtract from './removeExtract'
import removeOriginRelationship from './removeOriginRelationship'
import resetState from './resetState'
import saveConfidences from './saveConfidences'
import saveExtract from './saveExtract'
import saveIdentifiers from './saveIdentifiers'
import saveOriginRelationship from './saveOriginRelationships'
import saveProtocols from './saveProtocols'

const ActionFunctions = {
  [ActionNames.LoadConfidence]: loadConfidences,
  [ActionNames.LoadExtract]: loadExtract,
  [ActionNames.LoadIdentifiers]: loadIdentifiers,
  [ActionNames.LoadOriginRelationship]: loadOriginRelationship,
  [ActionNames.LoadProjectPreferences]: loadProjectPreferences,
  [ActionNames.LoadProtocols]: loadProtocols,
  [ActionNames.LoadRecents]: loadRecents,
  [ActionNames.LoadUserPreferences]: loadUserPreferences,
  [ActionNames.RemoveConfidence]: removeConfidence,
  [ActionNames.RemoveExtract]: removeExtract,
  [ActionNames.RemoveOriginRelationship]: removeOriginRelationship,
  [ActionNames.ResetState]: resetState,
  [ActionNames.SaveConfidences]: saveConfidences,
  [ActionNames.SaveExtract]: saveExtract,
  [ActionNames.SaveIdentifiers]: saveIdentifiers,
  [ActionNames.SaveOriginRelationship]: saveOriginRelationship,
  [ActionNames.SaveProtocols]: saveProtocols
}

export { ActionNames, ActionFunctions }
