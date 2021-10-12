import setTaxon from './setTaxon'
import setType from './setType'
import setBiologicalId from './setBiologicalId'
import setCitation from './setCitation'
import setProtonymId from './setProtonymId'
import setSaving from './setSaving'
import setLoading from './setLoading'
import setTypeMaterial from './setTypeMaterial'
import setTypeMaterials from './setTypeMaterials'
import removeTypeMaterial from './removeTypeMaterial'
import addTypeMaterial from './addTypeMaterial'
import setSoftValidation from './setSoftValidation'
import setSettings from './setSettings'

import setCollectionObjectBufferedDeterminations from './setCollectionObjectBufferedDeterminations'
import setCollectionObjectBufferedEvent from './setCollectionObjectBufferedEvent'
import setCollectionObjectBufferedLabels from './setCollectionObjectBufferedLabels'
import setCollectionObjectEventId from './setCollectionObjectEventId'
import setCollectionObjectId from './setCollectionObjectId'
import setCollectionObjectPreparationId from './setCollectionObjectPreparationId'
import setCollectionObjectRepositoryId from './setCollectionObjectRepositoryId'
import setCollectionObjectTotal from './setCollectionObjectTotal'
import setCollectionObject from './setCollectionObject'

const MutationNames = {
  SetTaxon: 'setTaxon',
  SetType: 'setType',
  SetBiologicalId: 'setBiologicalId',
  SetCitation: 'setCitation',
  SetProtonymId: 'setProtonymId',
  SetSaving: 'setSaving',
  SetLoading: 'setLoading',
  SetTypeMaterial: 'setTypeMaterial',
  SetTypeMaterials: 'setTypeMaterials',
  RemoveTypeMaterial: 'removeTypeMaterial',
  AddTypeMaterial: 'addTypeMaterial',
  SetCollectionObjectBufferedDeterminations: 'setCollectionObjectBufferedDeterminations',
  SetCollectionObjectBufferedEvent: 'setCollectionObjectBufferedEvent',
  SetCollectionObjectBufferedLabels: 'setCollectionObjectBufferedLabels',
  SetCollectionObjectEventId: 'setCollectionObjectEventId',
  SetCollectionObjectId: 'setCollectionObjectId',
  SetCollectionObjectPreparationId: 'setCollectionObjectPreparationId',
  SetCollectionObjectRepositoryId: 'setCollectionObjectRepositoryId',
  SetCollectionObjectTotal: 'setCollectionObjectTotal',
  SetCollectionObject: 'setCollectionObject',
  SetSoftValidation: 'setSoftValidation',
  SetSettings: 'setSettings'
}

const MutationFunctions = {
  [MutationNames.SetTaxon]: setTaxon,
  [MutationNames.SetType]: setType,
  [MutationNames.SetBiologicalId]: setBiologicalId,
  [MutationNames.SetCitation]: setCitation,
  [MutationNames.SetProtonymId]: setProtonymId,
  [MutationNames.SetSaving]: setSaving,
  [MutationNames.SetLoading]: setLoading,
  [MutationNames.SetTypeMaterial]: setTypeMaterial,
  [MutationNames.SetTypeMaterials]: setTypeMaterials,
  [MutationNames.RemoveTypeMaterial]: removeTypeMaterial,
  [MutationNames.AddTypeMaterial]: addTypeMaterial,
  [MutationNames.SetCollectionObjectBufferedDeterminations]: setCollectionObjectBufferedDeterminations,
  [MutationNames.SetCollectionObjectBufferedEvent]: setCollectionObjectBufferedEvent,
  [MutationNames.SetCollectionObjectBufferedLabels]: setCollectionObjectBufferedLabels,
  [MutationNames.SetCollectionObjectEventId]: setCollectionObjectEventId,
  [MutationNames.SetCollectionObjectRepositoryId]: setCollectionObjectRepositoryId,
  [MutationNames.SetCollectionObjectId]: setCollectionObjectId,
  [MutationNames.SetCollectionObjectPreparationId]: setCollectionObjectPreparationId,
  [MutationNames.SetCollectionObjectTotal]: setCollectionObjectTotal,
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.SetSettings]: setSettings
}

export {
  MutationNames,
  MutationFunctions
}
