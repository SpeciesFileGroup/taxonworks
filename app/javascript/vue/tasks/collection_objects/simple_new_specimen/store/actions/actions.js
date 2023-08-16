import ActionNames from './actionNames.js'
import createCollectionObject from './createCollectionObject.js'
import createCollectingEvent from './createCollectingEvent.js'
import createIdentifier from './createIdentifier.js'
import createNewSpecimen from './createNewSpecimen.js'
import createTaxonDetermination from './createTaxonDetermination.js'
import getIdentifiers from './getIdentifiers.js'
import getRecent from './getRecent.js'
import resetStore from './resetStore.js'

const ActionFunctions = {
  [ActionNames.CreateCollectionObject]: createCollectionObject,
  [ActionNames.CreateCollectingEvent]: createCollectingEvent,
  [ActionNames.CreateIdentifier]: createIdentifier,
  [ActionNames.CreateNewSpecimen]: createNewSpecimen,
  [ActionNames.CreateTaxonDetermination]: createTaxonDetermination,
  [ActionNames.GetIdentifiers]: getIdentifiers,
  [ActionNames.GetRecent]: getRecent,
  [ActionNames.ResetStore]: resetStore
}

export {
  ActionNames,
  ActionFunctions
}
