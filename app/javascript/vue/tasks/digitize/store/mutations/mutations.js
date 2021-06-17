import setGeographicArea from './setGeographicArea'
import setSubsequentialUses from './setSubsequentialUses'

import setLocked from './setLocked'
import lockAll from './lockAll'

import setSettings from './setSettings'
import setContainer from './Container/SetContainer'
import addContainerItem from './Container/AddContainerItem'
import setPreferences from './setPreferences'
import setPreparationType from './setPreparationType'

import resetStore from './resetStore'

import setDepictions from './setDepictions'

import setNamespaceSelected from './setNamespaceSelected'

import setBiocurations from './setBiocurations'
import addBiocuration from './addBiocuration'
import removeBiocuration from './removeBiocuration'

import setLabel from './Label/setLabel'
import setLabelText from './Label/setLabelText'
import setLabelTotal from './Label/setLabelTotal'
import setComponentsOrder from './setComponentsOrder'

import setCollectionObjects from './CollectionObject/setCollectionObjects'
import setCollectionObjectDataAttributes from './CollectionObject/setCollectionObjectDataAttributes'
import newCollectionObject from './CollectionObject/newCollectionObject'
import addCollectionObject from './CollectionObject/addCollectionObject'
import removeCollectionObject from './CollectionObject/removeCollectionObject'
import setCollectionObjectTypes from './CollectionObject/setCollectionObjectTypes'
import setCollectionObject from './CollectionObject/setCollectionObject'
import setCollectionObjectBufferedCollectionEvent from './CollectionObject/setCollectionObjectBufferedCollectionEvent'
import setCollectionObjectBufferedDeterminations from './CollectionObject/setCollectionObjectBufferedDeterminations'
import setCollectionObjectBufferedOtherLabel from './CollectionObject/setCollectionObjectBufferedOtherLabel'
import setCollectionObjectCollectionEventAttributes from './CollectionObject/setCollectionObjectCollectionEventAttributes'
import setCollectionObjectConteiner from './CollectionObject/setCollectionObjectConteiner'
import setCollectionObjectDeaccessionedAt from './CollectionObject/setCollectionObjectDeaccessionedAt'
import setCollectionObjectDeaccessionReason from './CollectionObject/setCollectionObjectDeaccessionReason'
import setCollectionObjectEventId from './CollectionObject/setCollectionObjectEventId'
import setCollectionObjectPreparationId from './CollectionObject/setCollectionObjectPreparationId'
import setCollectionObjectRangeLotId from './CollectionObject/setCollectionObjectRangeLotId'
import setCollectionObjectRepositoryId from './CollectionObject/setCollectionObjectRepositoryId'
import setCollectionObjectTotal from './CollectionObject/setCollectionObjectTotal'

import setCollectionEvent from './CollectionEvent/setCollectionEvent'
import setCollectionEventDataAttributes from './CollectionEvent/setCollectionEventDataAttributes'
import setCollectionEventGeographicArea from './CollectionEvent/setCollectionEventGeographicArea'
import setCollectionEventFormation from './CollectionEvent/setCollectionEventFormation'
import setCollectionEventGroup from './CollectionEvent/setCollectionEventGroup'
import setCollectionEventPrintLabel from './CollectionEvent/setCollectionEventPrintLabel'
import setCollectionEventDocumentLabel from './CollectionEvent/setCollectionEventDocumentLabel'
import setCollectionEventLabel from './CollectionEvent/setCollectionEventLabel'
import setCollectionEventCollectors from './CollectionEvent/setCollectionEventCollectors'
import setCollectionEventDate from './CollectionEvent/setCollectionEventDate'
import setCollectionEventTimeStartHour from './CollectionEvent/setCollectionEventTimeStartHour'
import setCollectionEventTimeStartMinute from './CollectionEvent/setCollectionEventTimeStartMinute'
import setCollectionEventTimeStartSecond from './CollectionEvent/setCollectionEventTimeStartSecond'
import setCollectionEventTimeEndHour from './CollectionEvent/setCollectionEventTimeEndHour'
import setCollectionEventTimeEndMinute from './CollectionEvent/setCollectionEventTimeEndMinute'
import setCollectionEventTimeEndSecond from './CollectionEvent/setCollectionEventTimeEndSecond'
import setCollectionEventStartDateDay from './CollectionEvent/setCollectionEventStartDateDay'
import setCollectionEventStartDateMonth from './CollectionEvent/setCollectionEventStartDateMonth'
import setCollectionEventStartDateYear from './CollectionEvent/setCollectionEventStartDateYear'
import setCollectionEventEndDateDay from './CollectionEvent/setCollectionEventEndDateDay'
import setCollectionEventEndDateMonth from './CollectionEvent/setCollectionEventEndDateMonth'
import setCollectionEventEndDateYear from './CollectionEvent/setCollectionEventEndDateYear'
import setCollectionEventDatum from './CollectionEvent/setCollectionEventDatum'
import setCollectionEventElevation from './CollectionEvent/setCollectionEventElevation'
import setCollectionEventGeolocation from './CollectionEvent/setCollectionEventGeolocation'
import setCollectionEventHabitat from './CollectionEvent/setCollectionEventHabitat'
import setCollectionEventLatitude from './CollectionEvent/setCollectionEventLatitude'
import setCollectionEventLocality from './CollectionEvent/setCollectionEventLocality'
import setCollectionEventLongitude from './CollectionEvent/setCollectionEventLongitude'
import setCollectionEventMethod from './CollectionEvent/setCollectionEventMethod'
import setCollectionEventTripIdentifier from './CollectionEvent/setCollectionEventTripIdentifier'
import setCollectionEventElevationPrecision from './CollectionEvent/setCollectionEventElevationPrecision'
import setCollectionEventMaximumElevation from './CollectionEvent/setCollectionEventMaximumElevation'
import setCollectionEventMinimumElevation from './CollectionEvent/setCollectionEventMinimumElevation'
import setCollectionEventMaxMa from './CollectionEvent/setCollectionEventMaxMa'
import setCollectionEventMinMa from './CollectionEvent/setCollectionEventMinMa'
import setCollectionEventRoles from './CollectionEvent/setCollectionEventRoles'
import setCollectionEventIdentifier from './CollectionEvent/setCollectionEventIdentifier'

import setTypeMaterial from './TypeMaterial/setTypeMaterial'
import setTypeMaterials from './TypeMaterial/setTypeMaterials'
import setTypeMaterialCitation from './TypeMaterial/setTypeMaterialCitation'
import setTypeMaterialBiologicalObjectId from './TypeMaterial/setTypeMaterialBiologicalObjectId'
import setTypeMaterialCollectionObject from './TypeMaterial/setTypeMaterialCollectionObject'
import setTypeMaterialCollectionObjectId from './TypeMaterial/setTypeMaterialCollectionObjectId'
import setTypeMaterialDesignatorRoles from './TypeMaterial/setTypeMaterialDesignatorRoles'
import setTypeMaterialProtonymId from './TypeMaterial/setTypeMaterialProtonymId'
import setTypeMaterialRoles from './TypeMaterial/setTypeMaterialRoles'
import setTypeMaterialType from './TypeMaterial/setTypeMaterialType'
import setTypeMaterialTaxon from './TypeMaterial/setTypeMaterialTaxon'
import addTypeMaterial from './TypeMaterial/addMaterialTypes'
import newTypeMaterial from './TypeMaterial/newTypeMaterial'
import removeTypeMaterial from './TypeMaterial/removeTypeMaterial'

import setIdentifiers from './setIdentifiers'
import setIdentifier from './Identifier/setIdentifier'
import setIdentifierIdentifier from './Identifier/setIdentifierIdentifier'
import setIdentifierNamespaceId from './Identifier/setIdentifierNamespaceId'
import setIdentifierObjectId from './Identifier/setIdentifierObjectId'

import addTaxonDetermination from './TaxonDetermination/addTaxonDetermination'
import removeTaxonDetermination from './TaxonDetermination/removeTaxonDetermination'
import newTaxonDetermination from './TaxonDetermination/newTaxonDetermination'
import setTaxonDetermination from './TaxonDetermination/setTaxonDetermination'
import setTaxonDeterminations from './TaxonDetermination/setTaxonDeterminations'
import setTaxonDeterminationOtuId from './TaxonDetermination/setTaxonDeterminationOtuId'
import setTaxonDeterminationBiologicalId from './TaxonDetermination/setTaxonDeterminationBiologicalId'
import setTaxonDeterminationYear from './TaxonDetermination/setTaxonDeterminationYear'
import setTaxonDeterminationMonth from './TaxonDetermination/setTaxonDeterminationMonth'
import setTaxonDeterminationDay from './TaxonDetermination/setTaxonDeterminationDay'
import setTaxonDeterminationRoles from './TaxonDetermination/setTaxonDeterminationRoles'

import setTmpDataOtu from './tmpData/setTmpDataOtu'
import setProjectPreferences from './setProjectPreferences'

const MutationNames = {

  SetGeographicArea: 'setGeographicArea',
  SetTmpDataOtu: 'setTmpDataOtu',
  SetSubsequentialUses: 'setSubsequentialUses',

  SetLocked: 'setLocked',
  LockAll: 'lockAll',
  SetSettings: 'setSettings',

  SetContainer: 'setContainer',
  AddContainerItem: 'addContainerItem',
  SetPreferences: 'setPreferences',

  ResetStore: 'resetStore',

  SetDepictions: 'setDepictions',
  SetNamespaceSelected: 'setNamespaceSelected',

  SetLabel: 'setLabel',
  SetLabelText: 'setLabelText',
  SetLabelTotal: 'setLabelTotal',

  SetPreparationType: 'setPreparationType',

  SetBiocurations: 'setBiocurations',
  AddBiocuration: 'AddBiocuration',
  RemoveBiocuration: 'RemoveBiocuration',

  NewTaxonDetermination: 'newTaxonDetermination',
  RemoveTaxonDetermination: 'removeTaxonDetermination',
  AddTaxonDetermination: 'addTaxonDetermination',
  SetTaxonDeterminations: 'setTaxonDeterminations',
  SetTaxonDetermination: 'setTaxonDetermination',
  SetTaxonDeterminationBiologicalId: 'setTaxonDeterminationBiologicalId',
  SetTaxonDeterminationDay: 'setTaxonDeterminationDay',
  SetTaxonDeterminationMonth: 'setTaxonDeterminationMonth',
  SetTaxonDeterminationYear: 'setTaxonDeterminationYear',
  SetTaxonDeterminationRoles: 'setTaxonDeterminationRoles',
  SetTaxonDeterminationOtuId: 'setTaxonDeterminationOtuId',

  SetIdentifiers: 'setIdentifiers',
  SetIdentifier: 'setIdentifier',
  SetIdentifierIdentifier: 'setIdentifierIdentifier',
  SetIdentifierNamespaceId: 'setIdentifierNamespaceId',
  SetIdentifierObjectId: 'setIdentifierObjectId',

  SetTypeMaterial: 'setTypeMaterial',
  SetTypeMaterials: 'setTypeMaterials',
  SetTypeMaterialCitation: 'setTypeMaterialCitation',
  SetTypeMaterialBiologicalObjectId: 'setTypeMaterialBiologicalObjectId',
  SetTypeMaterialCollectionObject: 'setTypeMaterialCollectionObject',
  SetTypeMaterialCollectionObjectId: 'setTypeMaterialCollectionObjectId',
  SetTypeMaterialDesignatorRoles: 'setTypeMaterialDesignatorRoles',
  SetTypeMaterialProtonymId: 'setTypeMaterialProtonymId',
  SetTypeMaterialRoles: 'setTypeMaterialRoles',
  SetTypeMaterialType: 'setTypeMaterialType',
  SetTypeMaterialTaxon: 'setTypeMaterialTaxon',
  AddTypeMaterial: 'addTypeMaterial',
  NewTypeMaterial: 'newTypeMaterial',
  RemoveTypeMaterial: 'removeTypeMaterial',

  SetCollectionEvent: 'setCollectionEvent',
  SetCollectionEventDataAttributes: 'setCollectionEventDataAttributes',
  SetCollectionEventGeographicArea: 'setCollectionEventGeographicArea',
  SetCollectionEventGroup: 'setCollectionEventGroup',
  SetCollectionEventFormation: 'setCollectionFormation',
  SetCollectionEventPrintLabel: 'setCollectionEventPrintLabel',
  SetCollectionEventLabel: 'setCollectionEventLabel',
  SetCollectionEventDocumentLabel: 'setCollectionEventDocumentLabel',
  SetCollectionEventCollectors: 'setCollectionEventCollectors',
  SetCollectionEventDate: 'setCollectionEventDate',
  SetCollectionEventTimeStartHour: 'setCollectionEventTimeStartHour',
  SetCollectionEventTimeStartMinute: 'setCollectionEventTimeStartMinute',
  SetCollectionEventTimeStartSecond: 'setCollectionEventTimeStartSecond',
  SetCollectionEventTimeEndHour: 'setCollectionEventTimeEndHour',
  SetCollectionEventTimeEndMinute: 'setCollectionEventTimeEndMinute',
  SetCollectionEventTimeEndSecond: 'setCollectionEventTimeEndSecond',
  SetCollectionEventStartDateDay: 'setCollectionEventStartDateDay',
  SetCollectionEventStartDateMonth: 'setCollectionEventStartDateMonth',
  SetCollectionEventStartDateYear: 'setCollectionEventStartDateYear',
  SetCollectionEventEndDateDay: 'setCollectionEventEndDateDay',
  SetCollectionEventEndDateMonth: 'setCollectionEventEndDateMonth',
  SetCollectionEventEndDateYear: 'setCollectionEventEndDateYear',
  SetCollectionEventDatum: 'setCollectionEventDatum',
  SetCollectionEventElevation: 'setCollectionEventElevation',
  SetCollectionEventGeolocation: 'setCollectionEventGeolocation',
  SetCollectionEventHabitat: 'setCollectionEventHabitat',
  SetCollectionEventLatitude: 'setCollectionEventLatitude',
  SetCollectionEventLocality: 'setCollectionEventLocality',
  SetCollectionEventLongitude: 'setCollectionEventLongitude',
  SetCollectionEventMethod: 'setCollectionEventMethod',
  SetCollectionEventTripIdentifier: 'setCollectionEventTripIdentifier',
  SetCollectionEventElevationPrecision: 'setCollectionEventElevationPrecision',
  SetCollectionEventMaximumElevation: 'setCollectionEventMaximumElevation',
  SetCollectionEventMinimumElevation: 'setCollectionEventMinimumElevation',
  SetCollectionEventMaxMa: 'setCollectionEventMaxMa',
  SetCollectionEventMinMa: 'setCollectionEventMinMa',
  SetCollectionEventRoles: 'setCollectionEventRoles',
  SetCollectionEventIdentifier: 'setCollectionEventIdentifier',

  SetCollectionObjectDataAttributes: 'setCollectionObjectDataAttributes',
  SetCollectionObjectTypes: 'setCollectionObjectTypes',
  SetCollectionObject: 'setCollectionObject',
  NewCollectionObject: 'newCollectionObject',
  AddCollectionObject: 'addCollectionObject',
  RemoveCollectionObject: 'RemoveCollectionObject',
  SetCollectionObjects: 'setCollectionObjects',
  SetCollectionObjectBufferedCollectionEvent: 'setCollectionObjectBufferedCollectionEvent',
  SetCollectionObjectBufferedDeterminations: 'setCollectionObjectBufferedDeterminations',
  SetCollectionObjectBufferedOtherLabel: 'setCollectionObjectBufferedOtherLabel',
  SetCollectionObjectCollectionEventAttributes: 'setCollectionObjectCollectionEventAttributes',
  SetCollectionObjectConteiner: 'setCollectionObjectConteiner',
  SetCollectionObjectDeaccessionedAt: 'setCollectionObjectDeaccessionedAt',
  SetCollectionObjectDeaccessionReason: 'setCollectionObjectDeaccessionReason',
  SetCollectionObjectEventId: 'setCollectionObjectEventId',
  SetCollectionObjectPreparationId: 'setCollectionObjectPreparationId',
  SetCollectionObjectRangeLotId: 'setCollectionObjectRangeLotId',
  SetCollectionObjectRepositoryId: 'setCollectionObjectRepositoryId',
  SetCollectionObjectTotal: 'setCollectionObjectTotal',
  SetProjectPreferences: 'setProjectPreferences',
  SetComponentsOrder: 'setComponentsOrder'
}

const MutationFunctions = {
  [MutationNames.SetProjectPreferences]: setProjectPreferences,
  [MutationNames.SetGeographicArea]: setGeographicArea,
  [MutationNames.SetTmpDataOtu]: setTmpDataOtu,
  [MutationNames.SetSubsequentialUses]: setSubsequentialUses,

  [MutationNames.SetLocked]: setLocked,
  [MutationNames.LockAll]: lockAll,
  [MutationNames.SetSettings]: setSettings,

  [MutationNames.SetContainer]: setContainer,
  [MutationNames.AddContainerItem]: addContainerItem,
  [MutationNames.SetPreferences]: setPreferences,

  [MutationNames.SetPreparationType]: setPreparationType,
  [MutationNames.ResetStore]: resetStore,

  [MutationNames.SetDepictions]: setDepictions,
  [MutationNames.SetNamespaceSelected]: setNamespaceSelected,

  [MutationNames.SetBiocurations]: setBiocurations,
  [MutationNames.AddBiocuration]: addBiocuration,
  [MutationNames.RemoveBiocuration]: removeBiocuration,

  [MutationNames.AddTaxonDetermination]: addTaxonDetermination,
  [MutationNames.RemoveTaxonDetermination]: removeTaxonDetermination,
  [MutationNames.NewTaxonDetermination]: newTaxonDetermination,
  [MutationNames.SetTaxonDeterminations]: setTaxonDeterminations,
  [MutationNames.SetTaxonDetermination]: setTaxonDetermination,
  [MutationNames.SetTaxonDeterminationBiologicalId]: setTaxonDeterminationBiologicalId,
  [MutationNames.SetTaxonDeterminationOtuId]: setTaxonDeterminationOtuId,
  [MutationNames.SetTaxonDeterminationRoles]: setTaxonDeterminationRoles,
  [MutationNames.SetTaxonDeterminationDay]: setTaxonDeterminationDay,
  [MutationNames.SetTaxonDeterminationMonth]: setTaxonDeterminationMonth,
  [MutationNames.SetTaxonDeterminationYear]: setTaxonDeterminationYear,

  [MutationNames.SetIdentifiers]: setIdentifiers,
  [MutationNames.SetIdentifier]: setIdentifier,
  [MutationNames.SetIdentifierIdentifier]: setIdentifierIdentifier,
  [MutationNames.SetIdentifierNamespaceId]: setIdentifierNamespaceId,
  [MutationNames.SetIdentifierObjectId]: setIdentifierObjectId,

  [MutationNames.SetTypeMaterial]: setTypeMaterial,
  [MutationNames.SetTypeMaterials]: setTypeMaterials,
  [MutationNames.SetTypeMaterialCitation]: setTypeMaterialCitation,
  [MutationNames.SetTypeMaterialBiologicalObjectId]: setTypeMaterialBiologicalObjectId,
  [MutationNames.SetTypeMaterialCollectionObject]: setTypeMaterialCollectionObject,
  [MutationNames.SetTypeMaterialCollectionObjectId]: setTypeMaterialCollectionObjectId,
  [MutationNames.SetTypeMaterialDesignatorRoles]: setTypeMaterialDesignatorRoles,
  [MutationNames.SetTypeMaterialProtonymId]: setTypeMaterialProtonymId,
  [MutationNames.SetTypeMaterialRoles]: setTypeMaterialRoles,
  [MutationNames.SetTypeMaterialType]: setTypeMaterialType,
  [MutationNames.SetTypeMaterialTaxon]: setTypeMaterialTaxon,
  [MutationNames.AddTypeMaterial]: addTypeMaterial,
  [MutationNames.NewTypeMaterial]: newTypeMaterial,
  [MutationNames.RemoveTypeMaterial]: removeTypeMaterial,

  [MutationNames.SetCollectionEvent]: setCollectionEvent,
  [MutationNames.SetCollectionEventDataAttributes]: setCollectionEventDataAttributes,
  [MutationNames.SetCollectionEventGeographicArea]: setCollectionEventGeographicArea,
  [MutationNames.SetCollectionEventFormation]: setCollectionEventFormation,
  [MutationNames.SetCollectionEventGroup]: setCollectionEventGroup,
  [MutationNames.SetCollectionEventDocumentLabel]: setCollectionEventDocumentLabel,
  [MutationNames.SetCollectionEventPrintLabel]: setCollectionEventPrintLabel,
  [MutationNames.SetCollectionEventLabel]: setCollectionEventLabel,
  [MutationNames.SetCollectionEventCollectors]: setCollectionEventCollectors,
  [MutationNames.SetCollectionEventDate]: setCollectionEventDate,
  [MutationNames.SetCollectionEventTimeStartHour]: setCollectionEventTimeStartHour,
  [MutationNames.SetCollectionEventTimeStartMinute]: setCollectionEventTimeStartMinute,
  [MutationNames.SetCollectionEventTimeStartSecond]: setCollectionEventTimeStartSecond,
  [MutationNames.SetCollectionEventTimeEndHour]: setCollectionEventTimeEndHour,
  [MutationNames.SetCollectionEventTimeEndMinute]: setCollectionEventTimeEndMinute,
  [MutationNames.SetCollectionEventTimeEndSecond]: setCollectionEventTimeEndSecond,
  [MutationNames.SetCollectionEventStartDateDay]: setCollectionEventStartDateDay,
  [MutationNames.SetCollectionEventStartDateMonth]: setCollectionEventStartDateMonth,
  [MutationNames.SetCollectionEventStartDateYear]: setCollectionEventStartDateYear,
  [MutationNames.SetCollectionEventEndDateDay]: setCollectionEventEndDateDay,
  [MutationNames.SetCollectionEventEndDateMonth]: setCollectionEventEndDateMonth,
  [MutationNames.SetCollectionEventEndDateYear]: setCollectionEventEndDateYear,
  [MutationNames.SetCollectionEventDatum]: setCollectionEventDatum,
  [MutationNames.SetCollectionEventElevation]: setCollectionEventElevation,
  [MutationNames.SetCollectionEventGeolocation]: setCollectionEventGeolocation,
  [MutationNames.SetCollectionEventHabitat]: setCollectionEventHabitat,
  [MutationNames.SetCollectionEventLatitude]: setCollectionEventLatitude,
  [MutationNames.SetCollectionEventLocality]: setCollectionEventLocality,
  [MutationNames.SetCollectionEventLongitude]: setCollectionEventLongitude,
  [MutationNames.SetCollectionEventMethod]: setCollectionEventMethod,
  [MutationNames.SetCollectionEventTripIdentifier]: setCollectionEventTripIdentifier,
  [MutationNames.SetCollectionEventElevationPrecision]: setCollectionEventElevationPrecision,
  [MutationNames.SetCollectionEventMaximumElevation]: setCollectionEventMaximumElevation,
  [MutationNames.SetCollectionEventMinimumElevation]: setCollectionEventMinimumElevation,
  [MutationNames.SetCollectionEventMaxMa]: setCollectionEventMaxMa,
  [MutationNames.SetCollectionEventMinMa]: setCollectionEventMinMa,
  [MutationNames.SetCollectionEventRoles]: setCollectionEventRoles,
  [MutationNames.SetCollectionEventIdentifier]: setCollectionEventIdentifier,

  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetCollectionObjectDataAttributes]: setCollectionObjectDataAttributes,
  [MutationNames.SetCollectionObjectTypes]: setCollectionObjectTypes,
  [MutationNames.AddCollectionObject]: addCollectionObject,
  [MutationNames.NewCollectionObject]: newCollectionObject,
  [MutationNames.RemoveCollectionObject]: removeCollectionObject,
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetCollectionObjectBufferedCollectionEvent]: setCollectionObjectBufferedCollectionEvent,
  [MutationNames.SetCollectionObjectBufferedDeterminations]: setCollectionObjectBufferedDeterminations,
  [MutationNames.SetCollectionObjectBufferedOtherLabel]: setCollectionObjectBufferedOtherLabel,
  [MutationNames.SetCollectionObjectCollectionEventAttributes]: setCollectionObjectCollectionEventAttributes,
  [MutationNames.SetCollectionObjectConteiner]: setCollectionObjectConteiner,
  [MutationNames.SetCollectionObjectDeaccessionedAt]: setCollectionObjectDeaccessionedAt,
  [MutationNames.SetCollectionObjectDeaccessionReason]: setCollectionObjectDeaccessionReason,
  [MutationNames.SetCollectionObjectEventId]: setCollectionObjectEventId,
  [MutationNames.SetCollectionObjectPreparationId]: setCollectionObjectPreparationId,
  [MutationNames.SetCollectionObjectRangeLotId]: setCollectionObjectRangeLotId,
  [MutationNames.SetCollectionObjectRepositoryId]: setCollectionObjectRepositoryId,
  [MutationNames.SetCollectionObjectTotal]: setCollectionObjectTotal,
  [MutationNames.SetComponentsOrder]: setComponentsOrder,

  [MutationNames.SetLabel]: setLabel,
  [MutationNames.SetLabelText]: setLabelText,
  [MutationNames.SetLabelTotal]: setLabelTotal
}

export {
  MutationNames,
  MutationFunctions
}
