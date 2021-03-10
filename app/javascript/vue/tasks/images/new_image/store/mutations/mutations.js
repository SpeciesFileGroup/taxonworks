import addAttribution from './addAttribution'
import addCitation from './addCitation'
import addDataAttribute from './addDataAttribute'
import addDepiction from './addDepiction'
import addObjectForDepictions from './addObjectForDepictions'
import addTag from './addTag'
import removeObjectForDepictions from './removeObjectForDepictions'
import resetStore from './resetStore'
import setAttributionsCreated from './setAttributionsCreated'
import setAuthors from './setAuthors'
import setCollectionObject from './setCollectionObject'
import setCopyrightHolders from './setCopyrightHolder'
import setDataAttributes from './setDataAttributes'
import setDepictionCaption from './setDepictionCaption'
import setDepictions from './setDepictions'
import setEditors from './setEditors'
import setImagesCreated from './setImagesCreated'
import setLicense from './setLicense'
import setNewCOForSqed from './setNewCOForSqed'
import setOwners from './setOwners'
import setPixels from './setPixels'
import setRepository from './setRepository'
import setSource from './setSource'
import setSqed from './setSqed'
import setTags from './setTags'
import setTaxonDetermination from './setTaxonDetermination'
import setTaxonDeterminations from './setTaxonDeterminations'
import setYearCopyright from './setYearCopyright'

const MutationNames = {
  AddAttribution: 'addAttribution',
  AddCitation: 'addCitation',
  AddDataAttribute: 'addDataAtributte',
  AddDepiction: 'addDepiction',
  AddObjectForDepictions: 'addObjectForDepictions',
  AddTag: 'addTag',
  RemoveObjectForDepictions: 'removeObjectForDepictions',
  ResetStore: 'resetStore',
  SetAttributionsCreated: 'setAttributionsCreated',
  SetAuthors: 'setAuthors',
  SetCollectionObject: 'setCollectionObject',
  SetCopyrightHolder: 'setCopyrightHolder',
  SetDataAttributes: 'setDataAttributes',
  SetDepictionCaption: 'setDepictionCaption',
  SetDepictions: 'setDepictions',
  SetEditors: 'SetEditors',
  SetImagesCreated: 'setImagesCreated',
  SetLicense: 'setLicense',
  SetNewCOForSqed: 'setNewCOForSqed',
  SetOwners: 'setOwners',
  SetPixels: 'setPixels',
  SetRepository: 'setRepository',
  SetSource: 'setSource',
  SetSqed: 'setSqed',
  SetTags: 'setTags',
  SetTaxonDetermination: 'setTaxonDetermination',
  SetTaxonDeterminations: 'setTaxonDeterminations',
  SetYearCopyright: 'setYearCopyright'
}

const MutationFunctions = {
  [MutationNames.AddAttribution]: addAttribution,
  [MutationNames.AddCitation]: addCitation,
  [MutationNames.AddDataAttribute]: addDataAttribute,
  [MutationNames.AddDepiction]: addDepiction,
  [MutationNames.AddObjectForDepictions]: addObjectForDepictions,
  [MutationNames.AddTag]: addTag,
  [MutationNames.RemoveObjectForDepictions]: removeObjectForDepictions,
  [MutationNames.ResetStore]: resetStore,
  [MutationNames.SetAttributionsCreated]: setAttributionsCreated,
  [MutationNames.SetAuthors]: setAuthors,
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetCopyrightHolder]: setCopyrightHolders,
  [MutationNames.SetDataAttributes]: setDataAttributes,
  [MutationNames.SetDepictionCaption]: setDepictionCaption,
  [MutationNames.SetDepictions]: setDepictions,
  [MutationNames.SetEditors]: setEditors,
  [MutationNames.SetImagesCreated]: setImagesCreated,
  [MutationNames.SetLicense]: setLicense,
  [MutationNames.SetNewCOForSqed]: setNewCOForSqed,
  [MutationNames.SetOwners]: setOwners,
  [MutationNames.SetPixels]: setPixels,
  [MutationNames.SetRepository]: setRepository,
  [MutationNames.SetSource]: setSource,
  [MutationNames.SetSqed]: setSqed,
  [MutationNames.SetTags]: setTags,
  [MutationNames.SetTaxonDetermination]: setTaxonDetermination,
  [MutationNames.SetTaxonDeterminations]: setTaxonDeterminations,
  [MutationNames.SetYearCopyright]: setYearCopyright
}

export {
  MutationNames,
  MutationFunctions
}
