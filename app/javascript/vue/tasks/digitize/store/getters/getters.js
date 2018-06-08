import getCollectionEvent from './getCollectionEvent'
import getCollectionEventLabel from './getCollectionEventLabel'

const GetterNames = {
  GetCollectionEvent: 'getCollectionEvent',
  GetCollectionEventLabel: 'getCollectionEventLabel',
}

const GetterFunctions = {
  [GetterNames.GetCollectionEventLabel]: getCollectionEventLabel,
  [GetterNames.GetCollectionEvent]: getCollectionEvent
}

export {
  GetterNames,
  GetterFunctions
}
