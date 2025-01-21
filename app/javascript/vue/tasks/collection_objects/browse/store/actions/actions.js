import ActionNames from './actionNames.js'

import loadBiocurations from './loadBiocurations.js'
import loadCollectionObject from './loadCollectionObject'
import loadConveyances from './loadConveyances.js'
import loadDepictions from './loadDepictions.js'
import loadDwc from './loadDwc.js'
import loadSoftValidation from './loadSoftValidation.js'
import loadIdentifiersFor from './loadIdentifiersFor.js'
import loadTimeline from './loadTimeline.js'
import updateCollectingEvent from './updateCollectingEvent.js'
import resetState from './resetState.js'

const ActionFunctions = {
  [ActionNames.LoadBiocurations]: loadBiocurations,
  [ActionNames.LoadCollectionObject]: loadCollectionObject,
  [ActionNames.LoadConveyances]: loadConveyances,
  [ActionNames.LoadDepictions]: loadDepictions,
  [ActionNames.LoadDwc]: loadDwc,
  [ActionNames.LoadIdentifiersFor]: loadIdentifiersFor,
  [ActionNames.LoadSoftValidation]: loadSoftValidation,
  [ActionNames.LoadTimeline]: loadTimeline,
  [ActionNames.UpdateCollectingEvent]: updateCollectingEvent,
  [ActionNames.ResetStore]: resetState
}

export { ActionFunctions, ActionNames }
