import {
  COLLECTION_OBJECT,
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  IDENTIFIER_LOCAL_FIELD_NUMBER
} from '@/constants/index.js'
import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import {
  ComponentMap,
  ComponentParse,
  ComponentVerbatim,
  ComponentLeftColumn
} from '../const/components'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeCollectionObject from '@/factory/CollectionObject.js'
import makeLabel from '@/factory/Label.js'
import makeIdentifier from '@/factory/Identifier.js'
import makeTypeMaterial from '@/factory/TypeMaterial.js'
import { reactive } from 'vue'

function makeInitialState() {
  return reactive({
    settings: {
      increment: false,
      incrementRecordNumber: false,
      isLocked: false,
      lastChange: 0,
      lastSave: 0,
      loading: false,
      saveIdentifier: true,
      saving: false,
      locked: {
        biocuration: false,
        biologicalAssociations: false,
        taxonDeterminations: false,
        coCitations: false,
        collecting_event: false,
        collection_object: {
          buffered_collecting_event: false,
          buffered_determinations: false,
          buffered_other_labels: false,
          preparation_type_id: false,
          repository_id: false,
          current_repository_id: false
        },
        recordNumber: false,
        identifier: false,
        taxon_determination: {
          otu_id: false,
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
    identifier: makeIdentifier(
      IDENTIFIER_LOCAL_CATALOG_NUMBER,
      COLLECTION_OBJECT
    ),
    collectingEventIdentifier: makeIdentifier(
      IDENTIFIER_LOCAL_FIELD_NUMBER,
      COLLECTING_EVENT
    ),
    coCitations: [],
    collecting_event: makeCollectingEvent(),
    collection_object: makeCollectionObject(),
    geographicArea: undefined,
    label: makeLabel(COLLECTING_EVENT),
    typeMaterial: makeTypeMaterial(),
    biocurations: [],
    biologicalAssociations: [],
    collection_objects: [],
    container: undefined,
    containerItems: [],
    depictions: [],
    identifiers: [],
    georeferences: [],
    materialTypes: [],
    namespaceSelected: undefined,
    preferences: {},
    preparation_type_id: undefined,
    project_preferences: undefined,
    softValidations: [],
    subsequentialUses: 0,
    ceTotalUsed: 0,
    typeSpecimens: [],
    existingIdentifiers: [],
    componentsOrder: {
      leftColumn: Object.values(ComponentLeftColumn),
      ComponentParse: Object.values(ComponentParse),
      ComponentVerbatim: Object.values(ComponentVerbatim),
      ComponentMap: Object.values(ComponentMap)
    }
  })
}

function newStore() {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}

export { newStore, makeInitialState }
