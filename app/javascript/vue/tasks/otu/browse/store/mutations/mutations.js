import setBiologicalAssociations from './setBiologicalAssociations'
import setCollectionObjects from './setCollectionObjects'
import setConveyances from './setConveyances'
import setGeoreferences from './setGeoreferences'
import setPreferences from './setPreferences'
import setAssertedDistributions from './setAssertedDistributions'
import setCurrentOtu from './setCurrentOtu'
import setDescendants from './setDescendants'
import setLoadState from './setLoadState'
import setTaxonName from './setTaxonName'
import setTaxonNames from './setTaxonNames'
import setOtus from './setOtus'
import setStore from './setStore'
import setDepictions from './setDepictions'
import setCommonNames from './setCommonNames'
import setObservationsDepictions from './setObservationsDepictions'
import setFieldOccurrences from './setFieldOccurrences'

const MutationNames = {
  SetBiologicalAssociations: 'setBiologicalAssociations',
  SetCollectionObjects: 'setCollectionObjects',
  SetCommonNames: 'setCommonNames',
  SetConveyances: 'setConveyances',
  SetDepictions: 'setDepictions',
  SetGeoreferences: 'setGeoreferences',
  SetPreferences: 'setPreferences',
  SetAssertedDistributions: 'setAssertedDistributions',
  SetCurrentOtu: 'setCurrentOtu',
  SetDescendants: 'setDescendants',
  SetFieldOccurrences: 'setFieldOccurrences',
  SetLoadState: 'setLoadState',
  SetTaxonName: 'setTaxonName',
  SetTaxonNames: 'setTaxonNames',
  SetObservationsDepictions: 'setObservationsDepictions',
  SetOtus: 'setOtus',
  SetStore: 'setStore'
}

const MutationFunctions = {
  [MutationNames.SetBiologicalAssociations]: setBiologicalAssociations,
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetCommonNames]: setCommonNames,
  [MutationNames.SetConveyances]: setConveyances,
  [MutationNames.SetDepictions]: setDepictions,
  [MutationNames.SetGeoreferences]: setGeoreferences,
  [MutationNames.SetPreferences]: setPreferences,
  [MutationNames.SetAssertedDistributions]: setAssertedDistributions,
  [MutationNames.SetCurrentOtu]: setCurrentOtu,
  [MutationNames.SetDescendants]: setDescendants,
  [MutationNames.SetFieldOccurrences]: setFieldOccurrences,
  [MutationNames.SetLoadState]: setLoadState,
  [MutationNames.SetTaxonName]: setTaxonName,
  [MutationNames.SetTaxonNames]: setTaxonNames,
  [MutationNames.SetObservationsDepictions]: setObservationsDepictions,
  [MutationNames.SetOtus]: setOtus,
  [MutationNames.SetStore]: setStore
}

export { MutationNames, MutationFunctions }
