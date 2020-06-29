import getAllRanks from './getAllRanks'
import activeModalStatus from './activeModalStatus'
import activeModalType from './activeModalType'
import activeModalRelationship from './activeModalRelationship'
import getParent from './getParent'
import getRankClass from './getRankClass'
import getRankList from './getRankList'
import getRelationshipList from './getRelationshipList'
import getStatusList from './getStatusList'
import getTaxonStatusList from './getTaxonStatusList'
import getTaxonRelationshipList from './getTaxonRelationshipList'
import getTaxonRelationship from './getTaxonRelationship'
import getTaxonType from './getTaxonType'
import getTaxonAuthor from './getTaxonAuthor'
import getTaxonFeminine from './getTaxonFeminine'
import getTaxonMasculine from './getTaxonMasculine'
import getTaxonNeuter from './getTaxonNeuter'
import getTaxonName from './getTaxonName'
import getTaxon from './getTaxon'
import getRoles from './getRoles'
import getParentRankGroup from './getParentRankGroup'
import getTaxonYearPublication from './getTaxonYearPublication'
import getNomenclaturalCode from './getNomenclaturalCode'
import getSoftValidation from './getSoftValidation'
import getHardValidation from './getHardValidation'
import getOriginalCombination from './getOriginalCombination'
import getCitation from './getCitation'
import getEtymology from './getEtymology'
import getLastChange from './getLastChange'
import getSaving from './getSaving'
import getLastSave from './getLastSave'
import getInitLoad from './getInitLoad'
import getAutosave from './getAutosave'

const GetterNames = {
  GetAllRanks: 'getAllRanks',
  ActiveModalStatus: 'activeModalStatus',
  ActiveModalType: 'activeModalType',
  ActiveModalRelationship: 'activeModalRelationship',
  GetParent: 'getParent',
  GetRankClass: 'getRankClass',
  GetRankList: 'getRankList',
  GetRelationshipList: 'getRelationshipList',
  GetStatusList: 'getStatusList',
  GetTaxonStatusList: 'getTaxonStatusList',
  GetTaxonRelationshipList: 'getTaxonRelationshipList',
  GetTaxonRelationship: 'getTaxonRelationship',
  GetTaxonType: 'getTaxonType',
  GetTaxonAuthor: 'getTaxonAuthor',
  GetTaxonFeminine: 'getTaxonFeminine',
  GetTaxonMasculine: 'getTaxonMasculine',
  GetTaxonNeuter: 'getTaxonNeuter',
  GetTaxonName: 'getTaxonName',
  GetTaxon: 'getTaxon',
  GetRoles: 'getRoles',
  GetParentRankGroup: 'getParentRankGroup',
  GetTaxonYearPublication: 'getTaxonYearPublication',
  GetNomenclaturalCode: 'getNomenclaturalCode',
  GetSoftValidation: 'getSoftValidation',
  GetHardValidation: 'getHardValidation',
  GetOriginalCombination: 'getOriginalCombination',
  GetCitation: 'getCitation',
  GetEtymology: 'getEtymology',
  GetLastChange: 'getLastChange',
  GetSaving: 'getSaving',
  GetLastSave: 'getLastSave',
  GetInitLoad: 'getInitLoad',
  GetAutosave: 'getAutosave'
}

const GetterFunctions = {
  [GetterNames.ActiveModalStatus]: activeModalStatus,
  [GetterNames.ActiveModalType]: activeModalType,
  [GetterNames.ActiveModalRelationship]: activeModalRelationship,
  [GetterNames.GetAllRanks]: getAllRanks,
  [GetterNames.GetParent]: getParent,
  [GetterNames.GetSaving]: getSaving,
  [GetterNames.GetRankClass]: getRankClass,
  [GetterNames.GetRelationshipList]: getRelationshipList,
  [GetterNames.GetRankList]: getRankList,
  [GetterNames.GetStatusList]: getStatusList,
  [GetterNames.GetTaxonStatusList]: getTaxonStatusList,
  [GetterNames.GetTaxonRelationship]: getTaxonRelationship,
  [GetterNames.GetTaxonType]: getTaxonType,
  [GetterNames.GetTaxonRelationshipList]: getTaxonRelationshipList,
  [GetterNames.GetTaxonAuthor]: getTaxonAuthor,
  [GetterNames.GetTaxonFeminine]: getTaxonFeminine,
  [GetterNames.GetTaxonMasculine]: getTaxonMasculine,
  [GetterNames.GetTaxonNeuter]: getTaxonNeuter,
  [GetterNames.GetTaxonName]: getTaxonName,
  [GetterNames.GetTaxon]: getTaxon,
  [GetterNames.GetRoles]: getRoles,
  [GetterNames.GetParentRankGroup]: getParentRankGroup,
  [GetterNames.GetTaxonYearPublication]: getTaxonYearPublication,
  [GetterNames.GetNomenclaturalCode]: getNomenclaturalCode,
  [GetterNames.GetOriginalCombination]: getOriginalCombination,
  [GetterNames.GetSoftValidation]: getSoftValidation,
  [GetterNames.GetHardValidation]: getHardValidation,
  [GetterNames.GetCitation]: getCitation,
  [GetterNames.GetEtymology]: getEtymology,
  [GetterNames.GetLastChange]: getLastChange,
  [GetterNames.GetLastSave]: getLastSave,
  [GetterNames.GetInitLoad]: getInitLoad,
  [GetterNames.GetAutosave]: getAutosave
}

export {
  GetterNames,
  GetterFunctions
}
