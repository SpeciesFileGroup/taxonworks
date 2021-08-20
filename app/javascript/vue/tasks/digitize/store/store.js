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
          repository_id: false
        },
        identifier: false,
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
    collection_event: makeCollectingEvent(),
    collection_object: makeCollectionObject(),
    geographicArea: undefined,
    label: makeLabel(),
    type_material: makeTypeMaterial(),
    tmpData: {
      otu: undefined
    },
    COTypes: [],
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
