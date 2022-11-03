import ActionNames from './actionNames.js'

import loadBiocurations from './loadBiocurations.js'
import loadCollectionObject from './loadCollectionObject'
import loadSoftValidation from './loadSoftValidation.js'
import loadIdentifiersFor from './loadIdentifiersFor.js'
import updateCollectingEvent from './updateCollectingEvent.js'

const ActionFunctions = {
  [ActionNames.LoadBiocurations]: loadBiocurations,
  [ActionNames.LoadCollectionObject]: loadCollectionObject,
  [ActionNames.LoadIdentifiersFor]: loadIdentifiersFor,
  [ActionNames.LoadSoftValidation]: loadSoftValidation,
  [ActionNames.UpdateCollectingEvent]: updateCollectingEvent
}

export {
  ActionFunctions,
  ActionNames
}
