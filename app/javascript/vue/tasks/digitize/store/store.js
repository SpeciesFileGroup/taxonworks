import {
  COLLECTION_OBJECT,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants/index.js'
import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import { ComponentLeftColumn } from '../const/components'
import makeCollectionObject from '@/factory/CollectionObject.js'
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
    coCitations: [],
    collection_object: makeCollectionObject(),
    geographicArea: undefined,
    typeMaterial: makeTypeMaterial(),
    biocurations: [],
    biologicalAssociations: [],
    collection_objects: [],
    container: undefined,
    containerItems: [],
    depictions: [],
    materialTypes: [],
    namespaceSelected: undefined,
    preferences: {},
    preparation_type_id: undefined,
    project_preferences: undefined,
    softValidations: {},
    subsequentialUses: 0,
    ceTotalUsed: 0,
    typeSpecimens: [],
    componentsOrder: {
      leftColumn: Object.values(ComponentLeftColumn)
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
