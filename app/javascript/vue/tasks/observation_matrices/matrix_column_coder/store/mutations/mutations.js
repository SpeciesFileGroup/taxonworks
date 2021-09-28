import setCollectionObjects from './setCollectionObjects'
import setObservations from './setObservations'
import setObservationMatrix from './setObservationMatrix'
import setOtus from './setOtus'

const MutationNames = {
  SetCollectionObjects: 'setCollectionObjects',
  SetObservations: 'setObservations',
  SetObservationMatrix: 'setObservationMatrix',
  SetOtus: 'setOtus'
}

const MutationFunctions = {
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetOtus]: setOtus
}

export {
  MutationFunctions,
  MutationNames
}
