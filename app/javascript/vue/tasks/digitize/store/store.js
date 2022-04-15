import {
  COLLECTION_OBJECT,
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  IDENTIFIER_LOCAL_TRIP_CODE
} from 'constants/index.js'
import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import {
  ComponentMap,
  ComponentParse,
  ComponentVerbatim
} from '../const/components'
import makeCollectingEvent from 'factory/CollectingEvent.js'
import makeCollectionObject from 'factory/CollectionObject.js'
import makeTypeMaterial from 'factory/TypeMaterial.js'
import makeLabel from 'factory/Label.js'
import makeIdentifier from 'factory/Identifier.js'
import makeTaxonDetermination from 'factory/TaxonDetermination.js'
import { reactive } from 'vue'

function makeInitialState () {
  return reactive({
    settings: {
      increment: false,
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
    taxon_determination: makeTaxonDetermination(),
    identifier: makeIdentifier(IDENTIFIER_LOCAL_CATALOG_NUMBER, COLLECTION_OBJECT),
    collectingEventIdentifier: makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT),
    coCitations: [],
    collecting_event: makeCollectingEvent(),
    collection_object: makeCollectionObject(),
    geographicArea: undefined,
    label: makeLabel(COLLECTING_EVENT),
    type_material: makeTypeMaterial(),
    tmpData: {
      otu: undefined
    },
    biocurations: [],
    biologicalAssociations: [],
    collection_objects: [],
    container: undefined,
    containerItems: [],
    depictions: [],
    determinations: [],
    identifiers: [],
    georeferences: [],
    materialTypes: [],
    namespaceSelected: '',
    preferences: {},
    preparation_type_id: undefined,
    project_preferences: undefined,
    softValidations: [],
    subsequentialUses: 0,
    taxon_determinations: [],
    componentsOrder: {
      leftColumn: [
        'TaxonDeterminationLayout',
        'BiologicalAssociation',
        'TypeMaterial'
      ],
      ComponentParse: Object.values(ComponentParse),
      ComponentVerbatim: Object.values(ComponentVerbatim),
      ComponentMap: Object.values(ComponentMap)
    }
  })
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
