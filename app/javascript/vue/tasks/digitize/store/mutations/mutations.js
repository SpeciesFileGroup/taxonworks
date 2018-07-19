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

import setTypeMaterial from './TypeMaterial/setTypeMaterial'
import setTypeMaterialBiologicalObjectId from './TypeMaterial/setTypeMaterialBiologicalObjectId'
import setTypeMaterialCollectionObject from './TypeMaterial/setTypeMaterialCollectionObject'
import setTypeMaterialCollectionObjectId from './TypeMaterial/setTypeMaterialCollectionObjectId'
import setTypeMaterialDesignatorRoles from './TypeMaterial/setTypeMaterialDesignatorRoles'
import setTypeMaterialProtonymId from './TypeMaterial/setTypeMaterialProtonymId'
import setTypeMaterialRoles from './TypeMaterial/setTypeMaterialRoles'
import setTypeMaterialType from './TypeMaterial/setTypeMaterialType'
import setTypeMaterialTaxon from './TypeMaterial/setTypeMaterialTaxon'

import setIdentifier from './Identifier/setIdentifier'
import setIdentifierIdentifier from './Identifier/setIdentifierIdentifier'
import setIdentifierNamespaceId from './Identifier/setIdentifierNamespaceId'
import setIdentifierObjectId from './Identifier/setIdentifierObjectId'

import setTaxonDetermination from './TaxonDetermination/setTaxonDetermination'
import setTaxonDeterminationOtuId from './TaxonDetermination/setTaxonDeterminationOtuId'
import setTaxonDeterminationBiologicalId from './TaxonDetermination/setTaxonDeterminationBiologicalId'
import setTaxonDeterminationYear from './TaxonDetermination/setTaxonDeterminationYear'
import setTaxonDeterminationMonth from './TaxonDetermination/setTaxonDeterminationMonth'
import setTaxonDeterminationDay from './TaxonDetermination/setTaxonDeterminationDay'
import setTaxonDeterminationRoles from './TaxonDetermination/setTaxonDeterminationRoles'

const MutationNames = {
  SetTaxonDetermination: 'setTaxonDetermination',
  SetTaxonDeterminationBiologicalId: 'setTaxonDeterminationBiologicalId',
  SetTaxonDeterminationDay: 'setTaxonDeterminationDay',
  SetTaxonDeterminationMonth: 'setTaxonDeterminationMonth',
  SetTaxonDeterminationYear: 'setTaxonDeterminationYear',
  SetTaxonDeterminationRoles: 'setTaxonDeterminationRoles',
  SetTaxonDeterminationOtuId: 'setTaxonDeterminationOtuId',

  SetIdentifier: 'setIdentifier',
  SetIdentifierIdentifier: 'setIdentifierIdentifier',
  SetIdentifierNamespaceId: 'setIdentifierNamespaceId',
  SetIdentifierObjectId: 'setIdentifierObjectId',

  SetTypeMaterial: 'setTypeMaterial',
  SetTypeMaterialBiologicalObjectId: 'setTypeMaterialBiologicalObjectId',
  SetTypeMaterialCollectionObject: 'setTypeMaterialCollectionObject',
  SetTypeMaterialCollectionObjectId: 'setTypeMaterialCollectionObjectId',
  SetTypeMaterialDesignatorRoles: 'setTypeMaterialDesignatorRoles',
  SetTypeMaterialProtonymId: 'setTypeMaterialProtonymId',
  SetTypeMaterialRoles: 'setTypeMaterialRoles',
  SetTypeMaterialType: 'setTypeMaterialType',
  SetTypeMaterialTaxon: 'setTypeMaterialTaxon',

  SetCollectionEventLabel: 'setCollectionEventLabel',
  SetCollectionEventCollectors: 'setCollectionEventCollectors',
  SetCollectionEventDate: 'setCollectionEventDate',
  setCollectionEventTimeStartHour: 'setCollectionEventTimeStartHour',
  setCollectionEventTimeStartMinute: 'setCollectionEventTimeStartMinute',
  setCollectionEventTimeStartSecond: 'setCollectionEventTimeStartSecond',
  setCollectionEventTimeEndHour: 'setCollectionEventTimeEndHour',
  setCollectionEventTimeEndMinute: 'setCollectionEventTimeEndMinute',
  setCollectionEventTimeEndSecond: 'setCollectionEventTimeEndSecond',
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

  SetCollectionObject: 'setCollectionObject',
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
  SetCollectionObjectTotal: 'setCollectionObjectTotal'  
}

const MutationFunctions = {
  [MutationNames.SetTaxonDetermination]: setTaxonDetermination,
  [MutationNames.SetTaxonDeterminationBiologicalId]: setTaxonDeterminationBiologicalId,
  [MutationNames.SetTaxonDeterminationOtuId]: setTaxonDeterminationOtuId,
  [MutationNames.SetTaxonDeterminationRoles]: setTaxonDeterminationRoles,
  [MutationNames.SetTaxonDeterminationDay]: setTaxonDeterminationDay,
  [MutationNames.SetTaxonDeterminationMonth]: setTaxonDeterminationMonth,
  [MutationNames.SetTaxonDeterminationYear]: setTaxonDeterminationYear,

  [MutationNames.SetIdentifier]: setIdentifier,
  [MutationNames.SetIdentifierIdentifier]: setIdentifierIdentifier,
  [MutationNames.SetIdentifierNamespaceId]: setIdentifierNamespaceId,
  [MutationNames.SetIdentifierObjectId]: setIdentifierObjectId,

  [MutationNames.SetTypeMaterial]: setTypeMaterial,
  [MutationNames.SetTypeMaterialBiologicalObjectId]: setTypeMaterialBiologicalObjectId,
  [MutationNames.SetTypeMaterialCollectionObject]: setTypeMaterialCollectionObject,
  [MutationNames.SetTypeMaterialCollectionObjectId]: setTypeMaterialCollectionObjectId,
  [MutationNames.SetTypeMaterialDesignatorRoles]: setTypeMaterialDesignatorRoles,
  [MutationNames.SetTypeMaterialProtonymId]: setTypeMaterialProtonymId,
  [MutationNames.SetTypeMaterialRoles]: setTypeMaterialRoles,
  [MutationNames.SetTypeMaterialType]: setTypeMaterialType,
  [MutationNames.SetTypeMaterialTaxon]: setTypeMaterialTaxon,

  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetCollectionObjectBufferedCollectionEvent]: setCollectionObjectBufferedCollectionEvent,
  [MutationNames.SetCollectionEventLabel]: setCollectionEventLabel,
  [MutationNames.SetCollectionEventCollectors]: setCollectionEventCollectors,
  [MutationNames.SetCollectionEventDate]: setCollectionEventDate,
  [MutationNames.setCollectionEventTimeStartHour]: setCollectionEventTimeStartHour,
  [MutationNames.setCollectionEventTimeStartMinute]: setCollectionEventTimeStartMinute,
  [MutationNames.setCollectionEventTimeStartSecond]: setCollectionEventTimeStartSecond,
  [MutationNames.setCollectionEventTimeEndHour]: setCollectionEventTimeEndHour,
  [MutationNames.setCollectionEventTimeEndMinute]: setCollectionEventTimeEndMinute,
  [MutationNames.setCollectionEventTimeEndSecond]: setCollectionEventTimeEndSecond,
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
  [MutationNames.SetCollectionObjectTotal]: setCollectionObjectTotal
}

export {
  MutationNames,
  MutationFunctions
}
