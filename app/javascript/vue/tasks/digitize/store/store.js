import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import {
  ComponentMap,
  ComponentParse,
  ComponentVerbatim
} from '../const/components'
import ceInit from '../const/collectingEvent'

function makeInitialState () {
  return {
    settings: {
      saving: false,
      loading: false,
      increment: false,
      lastSave: 0,
      lastChange: 0,
      saveIdentifier: true,
      isLocked: false,
      locked: {
        biocuration: false,
        identifier: false,
        collecting_event: false,
        collection_object: {
          buffered_determinations: false,
          buffered_collecting_event: false,
          buffered_other_labels: false,
          repository_id: false,
          preparation_type_id: false
        },
        taxon_determination: {
          otu_id: false,
          year_made: false,
          month_made: false,
          day_made: false,
          dates: false,
          roles_attributes: false
        },
        biological_association: {
          relationship: false,
          related: false
        }
      },
      sortable: false
    },
    taxon_determination: {
      biological_collection_object_id: undefined,
      otu_id: undefined,
      year_made: undefined,
      month_made: undefined,
      day_made: undefined,
      roles_attributes: []
    },
    identifier: {
      id: undefined,
      namespace_id: undefined,
      type: 'Identifier::Local::CatalogNumber',
      identifier_object_id: undefined,
      identifier_object_type: 'CollectionObject',
      identifier: undefined
    },
    collectingEventIdentifier: {
      id: undefined,
      namespace_id: undefined,
      type: 'Identifier::Local::TripCode',
      identifier: undefined
    },
    collection_object: {
      id: undefined,
      global_id: undefined,
      total: 1,
      preparation_type_id: null,
      repository_id: undefined,
      ranged_lot_category_id: undefined,
      collecting_event_id: undefined,
      buffered_collecting_event: undefined,
      buffered_determinations: undefined,
      buffered_other_labels: undefined,
      deaccessioned_at: undefined,
      deaccession_reason: undefined,
      contained_in: undefined
    },
    collection_event: ceInit(),
    type_material: {
      id: undefined,
      global_id: undefined,
      protonym_id: undefined,
      taxon: undefined,
      collection_object_id: undefined,
      type_type: undefined,
      collection_object: undefined,
      origin_citation_attributes: undefined
    },
    label: {
      id: undefined,
      text: undefined,
      total: undefined,
      label_object_id: undefined,
      label_object_type: 'CollectingEvent'
    },
    geographicArea: undefined,
    tmpData: {
      otu: undefined
    },
    subsequentialUses: 0,
    identifiers: [],
    materialTypes: [],
    determinations: [],
    preferences: {},
    project_preferences: undefined,
    container: undefined,
    containerItems: [],
    collection_objects: [],
    depictions: [],
    COTypes: [],
    biocurations: [],
    preparation_type_id: undefined,
    taxon_determinations: [],
    namespaceSelected: '',
    componentsOrder: {
      leftColumn: [
        'TaxonDeterminationLayout',
        'BiologicalAssociation',
        'TypeMaterial'
      ],
      ComponentParse: Object.keys(ComponentParse),
      ComponentVerbatim: Object.keys(ComponentVerbatim),
      ComponentMap: Object.keys(ComponentMap)
    }
  }
}

function newStore () {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}

export {
  newStore,
  makeInitialState
}
