import setSubsequentialUses from './setSubsequentialUses'

import setLocked from './setLocked'
import lockAll from './lockAll'

import setSettings from './setSettings'
import setContainer from './Container/SetContainer'
import addContainerItem from './Container/AddContainerItem'
import removeContainerItem from './Container/removeContainerItem'
import setPreferences from './setPreferences'
import setPreparationType from './setPreparationType'

import resetStore from './resetStore'

import setDepictions from './setDepictions'

import setNamespaceSelected from './setNamespaceSelected'

import setBiocurations from './setBiocurations'
import addBiocuration from './addBiocuration'
import removeBiocuration from './removeBiocuration'

import setComponentsOrder from './setComponentsOrder'

import setCollectionObjects from './CollectionObject/setCollectionObjects'
import newCollectionObject from './CollectionObject/newCollectionObject'
import addCollectionObject from './CollectionObject/addCollectionObject'
import removeCollectionObject from './CollectionObject/removeCollectionObject'
import setCollectionObject from './CollectionObject/setCollectionObject'
import setCOCitations from './setCOCitations'

import setTypeMaterial from './TypeMaterial/setTypeMaterial'
import setTypeMaterials from './TypeMaterial/setTypeMaterials'
import addTypeMaterial from './TypeMaterial/addMaterialTypes'
import newTypeMaterial from './TypeMaterial/newTypeMaterial'
import removeTypeMaterial from './TypeMaterial/removeTypeMaterial'

import setSoftValidations from './setSoftValidations'
import setBiologicalAssociations from './setBiologicalAssociations'

import setProjectPreferences from './setProjectPreferences'

const MutationNames = {
  SetBiologicalAssociations: 'setBiologicalAssociations',

  SetSubsequentialUses: 'setSubsequentialUses',

  SetLocked: 'setLocked',
  LockAll: 'lockAll',
  SetSettings: 'setSettings',

  SetContainer: 'setContainer',
  AddContainerItem: 'addContainerItem',
  RemoveContainerItem: 'removeContainerItem',
  SetPreferences: 'setPreferences',

  ResetStore: 'resetStore',

  SetDepictions: 'setDepictions',
  SetNamespaceSelected: 'setNamespaceSelected',

  SetPreparationType: 'setPreparationType',

  SetBiocurations: 'setBiocurations',
  AddBiocuration: 'AddBiocuration',
  RemoveBiocuration: 'RemoveBiocuration',

  SetTypeMaterial: 'setTypeMaterial',
  SetTypeMaterials: 'setTypeMaterials',
  AddTypeMaterial: 'addTypeMaterial',
  NewTypeMaterial: 'newTypeMaterial',
  RemoveTypeMaterial: 'removeTypeMaterial',

  SetCOCitations: 'setCOCitations',
  SetCollectionObject: 'setCollectionObject',
  NewCollectionObject: 'newCollectionObject',
  AddCollectionObject: 'addCollectionObject',
  RemoveCollectionObject: 'RemoveCollectionObject',
  SetCollectionObjects: 'setCollectionObjects',
  SetProjectPreferences: 'setProjectPreferences',
  SetComponentsOrder: 'setComponentsOrder',

  SetSoftValidations: 'setSoftValidations'
}

const MutationFunctions = {
  [MutationNames.SetBiologicalAssociations]: setBiologicalAssociations,
  [MutationNames.SetProjectPreferences]: setProjectPreferences,
  [MutationNames.SetSubsequentialUses]: setSubsequentialUses,

  [MutationNames.SetLocked]: setLocked,
  [MutationNames.LockAll]: lockAll,
  [MutationNames.SetSettings]: setSettings,

  [MutationNames.SetContainer]: setContainer,
  [MutationNames.AddContainerItem]: addContainerItem,
  [MutationNames.RemoveContainerItem]: removeContainerItem,
  [MutationNames.SetPreferences]: setPreferences,

  [MutationNames.SetPreparationType]: setPreparationType,
  [MutationNames.ResetStore]: resetStore,

  [MutationNames.SetDepictions]: setDepictions,
  [MutationNames.SetNamespaceSelected]: setNamespaceSelected,

  [MutationNames.SetBiocurations]: setBiocurations,
  [MutationNames.AddBiocuration]: addBiocuration,
  [MutationNames.RemoveBiocuration]: removeBiocuration,

  [MutationNames.AddTypeMaterial]: addTypeMaterial,
  [MutationNames.NewTypeMaterial]: newTypeMaterial,
  [MutationNames.RemoveTypeMaterial]: removeTypeMaterial,
  [MutationNames.SetTypeMaterial]: setTypeMaterial,
  [MutationNames.SetTypeMaterials]: setTypeMaterials,

  [MutationNames.SetCOCitations]: setCOCitations,
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.AddCollectionObject]: addCollectionObject,
  [MutationNames.NewCollectionObject]: newCollectionObject,
  [MutationNames.RemoveCollectionObject]: removeCollectionObject,
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetComponentsOrder]: setComponentsOrder,
  [MutationNames.SetSoftValidations]: setSoftValidations
}

export { MutationNames, MutationFunctions }
