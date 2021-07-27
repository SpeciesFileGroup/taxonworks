import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import {
  ComponentMap,
  ComponentParse,
  ComponentVerbatim
} from '../const/components'
import makeCollectingEvent from '../const/collectingEvent'
import makeCollectionObject from '../const/collectionObject'
import makeTypeMaterial from '../const/typeMaterial'
import makeLabel from '../const/label'
import makeIdentifier from '../const/identifier'
import makeTaxonDetermination from '../const/taxonDetermination'

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
        coCitations: false,
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
    taxon_determination: makeTaxonDetermination(),
    identifier: makeIdentifier(),
    collectingEventIdentifier: {
      id: undefined,
      namespace_id: undefined,
      type: 'Identifier::Local::TripCode',
      identifier: undefined
    },
    coCitations: [],
    collection_object: makeCollectionObject(),
    collection_event: makeCollectingEvent(),
    type_material: makeTypeMaterial(),
    label: makeLabel(),
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
      ComponentParse: Object.values(ComponentParse),
      ComponentVerbatim: Object.values(ComponentVerbatim),
      ComponentMap: Object.values(ComponentMap)
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
