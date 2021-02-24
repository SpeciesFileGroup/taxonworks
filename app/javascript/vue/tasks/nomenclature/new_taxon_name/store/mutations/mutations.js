import addTaxonStatus from './addTaxonStatus'
import addTaxonRelationship from './addTaxonRelationship'
import addOriginalCombination from './addOriginalCombination'
import removeTaxonStatus from './removeTaxonStatus'
import removeTaxonRelationship from './removeTaxonRelationship'
import removeOriginalCombination from './removeOriginalCombination'
import setInitLoad from './setInitLoad'
import setModalStatus from './setModalStatus'
import setModalType from './setModalType'
import setModalRelationship from './setModalRelationship'
import setAllRanks from './setAllRanks'
import setParent from './setParent'
import setParentId from './setParentId'
import setRankClass from './setRankClass'
import setRankList from './setRankList'
import setParentRankGroup from './setParentRankGroup'
import setRelationshipList from './setRelationshipList'
import setTaxonRelationshipList from './setTaxonRelationshipList'
import setStatusList from './setStatusList'
import setSaving from './setSaving'
import setTaxonRelationship from './setTaxonRelationship'
import setTaxonType from './setTaxonType'
import setTaxonStatusList from './setTaxonStatusList'
import setTaxonAuthor from './setTaxonAuthor'
import setTaxonMasculine from './setTaxonMasculine'
import setTaxonFeminine from './setTaxonFeminine'
import setTaxonNeuter from './setTaxonNeuter'
import setTaxonName from './setTaxonName'
import setTaxonId from './setTaxonId'
import setTaxon from './setTaxon'
import setRoles from './setRoles'
import setCitation from './setCitation'
import setEtymology from './setEtymology'
import setSoftValidation from './setSoftValidation'
import setHardValidation from './setHardValidation'
import setTaxonYearPublication from './setTaxonYearPublication'
import setOriginalCombination from './setOriginalCombination'
import setNomenclaturalCode from './setNomenclaturalCode'
import updateLastChange from './updateLastChange'
import updateLastSave from './updateLastSave'
import setAutosave from './setAutosave'

const MutationNames = {
  AddTaxonStatus: 'addTaxonStatus',
  AddTaxonRelationship: 'addTaxonRelationship',
  AddOriginalCombination: 'addOriginalCombination',
  RemoveTaxonStatus: 'removeTaxonStatus',
  RemoveTaxonRelationship: 'removeTaxonRelationship',
  RemoveOriginalCombination: 'removeOriginalCombination',
  SetAutosave: 'setAutosave',
  SetInitLoad: 'setInitLoad',
  SetModalStatus: 'setModalStatus',
  SetModalType: 'setModalType',
  SetModalRelationship: 'setModalRelationship',
  SetAllRanks: 'setAllRanks',
  SetParent: 'setParent',
  SetParentId: 'setParentId',
  SetRankClass: 'setRankClass',
  SetRankList: 'setRankList',
  SetParentRankGroup: 'setParentRankGroup',
  SetRelationshipList: 'setRelationshipList',
  SetTaxonRelationshipList: 'setTaxonRelationshipList',
  SetStatusList: 'setStatusList',
  SetSaving: 'setSaving',
  SetTaxonRelationship: 'setTaxonRelationship',
  SetTaxonType: 'setTaxonType',
  SetTaxonStatusList: 'setTaxonStatusList',
  SetTaxonAuthor: 'setTaxonAuthor',
  SetTaxonMasculine: 'setTaxonMasculine',
  SetTaxonFeminine: 'setTaxonFeminine',
  SetTaxonNeuter: 'setTaxonNeuter',
  SetTaxonName: 'setTaxonName',
  SetTaxonId: 'setTaxonId',
  SetTaxon: 'setTaxon',
  SetRoles: 'setRoles',
  SetCitation: 'setCitation',
  SetEtymology: 'setEtymology',
  SetSoftValidation: 'setSoftValidation',
  SetHardValidation: 'setHardValidation',
  SetTaxonYearPublication: 'setTaxonYearPublication',
  SetOriginalCombination: 'setOriginalCombination',
  SetNomenclaturalCode: 'setNomenclaturalCode',
  UpdateLastChange: 'updateLastChange',
  UpdateLastSave: 'updateLastSave'
}

const MutationFunctions = {
  [MutationNames.AddTaxonStatus]: addTaxonStatus,
  [MutationNames.AddTaxonRelationship]: addTaxonRelationship,
  [MutationNames.AddOriginalCombination]: addOriginalCombination,
  [MutationNames.RemoveTaxonStatus]: removeTaxonStatus,
  [MutationNames.RemoveTaxonRelationship]: removeTaxonRelationship,
  [MutationNames.RemoveOriginalCombination]: removeOriginalCombination,
  [MutationNames.SetAutosave]: setAutosave,
  [MutationNames.SetInitLoad]: setInitLoad,
  [MutationNames.SetModalStatus]: setModalStatus,
  [MutationNames.SetModalType]: setModalType,
  [MutationNames.SetTaxonType]: setTaxonType,
  [MutationNames.SetModalRelationship]: setModalRelationship,
  [MutationNames.SetAllRanks]: setAllRanks,
  [MutationNames.SetParent]: setParent,
  [MutationNames.SetParentId]: setParentId,
  [MutationNames.SetRelationshipList]: setRelationshipList,
  [MutationNames.SetRankClass]: setRankClass,
  [MutationNames.SetRankList]: setRankList,
  [MutationNames.SetStatusList]: setStatusList,
  [MutationNames.SetTaxonStatusList]: setTaxonStatusList,
  [MutationNames.SetTaxonRelationship]: setTaxonRelationship,
  [MutationNames.SetTaxonRelationshipList]: setTaxonRelationshipList,
  [MutationNames.SetTaxonAuthor]: setTaxonAuthor,
  [MutationNames.SetTaxonMasculine]: setTaxonMasculine,
  [MutationNames.SetTaxonFeminine]: setTaxonFeminine,
  [MutationNames.SetTaxonNeuter]: setTaxonNeuter,
  [MutationNames.SetTaxonName]: setTaxonName,
  [MutationNames.SetTaxonId]: setTaxonId,
  [MutationNames.SetTaxon]: setTaxon,
  [MutationNames.SetRoles]: setRoles,
  [MutationNames.SetSaving]: setSaving,
  [MutationNames.SetCitation]: setCitation,
  [MutationNames.SetEtymology]: setEtymology,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.SetHardValidation]: setHardValidation,
  [MutationNames.SetParentRankGroup]: setParentRankGroup,
  [MutationNames.SetTaxonYearPublication]: setTaxonYearPublication,
  [MutationNames.SetOriginalCombination]: setOriginalCombination,
  [MutationNames.SetNomenclaturalCode]: setNomenclaturalCode,
  [MutationNames.UpdateLastChange]: updateLastChange,
  [MutationNames.UpdateLastSave]: updateLastSave
}

export {
  MutationNames,
  MutationFunctions
}
