import ActionNames from './actionNames'
import cloneCollectingEvent from './cloneCollectingEvent'
import loadCollectingEvent from './loadCollectingEvent'
import loadCELabel from './loadCELabel'
import loadGeographicArea from './loadGeographicArea'
import loadGeoreferences from './loadGeoreferences'
import loadIdentifier from './loadIdentifier'
import loadSoftValidations from './loadSoftValidations'
import saveCELabel from './saveCELabel'
import saveCollectingEvent from './saveCollectingEvent'
import saveIdentifier from './saveIdentifier'
import processGeoreferenceQueue from './processGeoreferenceQueue'
import resetStore from './resetStore'

const ActionFunctions = {
  [ActionNames.CloneCollectingEvent]: cloneCollectingEvent,
  [ActionNames.LoadCELabel]: loadCELabel,
  [ActionNames.LoadCollectingEvent]: loadCollectingEvent,
  [ActionNames.LoadIdentifier]: loadIdentifier,
  [ActionNames.LoadGeographicArea]: loadGeographicArea,
  [ActionNames.LoadGeoreferences]: loadGeoreferences,
  [ActionNames.LoadSoftValidations]: loadSoftValidations,
  [ActionNames.SaveCELabel]: saveCELabel,
  [ActionNames.SaveCollectingEvent]: saveCollectingEvent,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.ProcessGeoreferenceQueue]: processGeoreferenceQueue,
  [ActionNames.ResetStore]: resetStore
}

export {
  ActionNames,
  ActionFunctions
}
