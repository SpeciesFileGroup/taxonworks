import ActionNames from './actionNames.js'

import loadBiocurations from './loadBiocurations.js'
import loadCollectionObject from './loadCollectionObject'
import loadIdentifiers from './loadIdentifiers'
import loadSoftValidation from './loadSoftValidation.js'

const ActionFunctions = {
  [ActionNames.LoadBiocurations]: loadBiocurations,
  [ActionNames.LoadCollectionObject]: loadCollectionObject,
  [ActionNames.LoadIdentifiers]: loadIdentifiers,
  [ActionNames.LoadSoftValidation]: loadSoftValidation
}

export {
  ActionFunctions,
  ActionNames
}
