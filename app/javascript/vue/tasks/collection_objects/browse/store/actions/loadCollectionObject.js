import {
  CollectionObject,
  CollectingEvent,
  Container,
  Georeference,
  TaxonDetermination,
  BiologicalAssociation,
  TypeMaterial,
  GeographicArea,
  Repository
} from '@/routes/endpoints'
import { sortArray } from '@/helpers'
import { makeCollectionObject } from '@/adapters/index.js'
import { COLLECTION_OBJECT, COLLECTING_EVENT } from '@/constants/index.js'
import ActionNames from './actionNames'

export default ({ state, dispatch }, coId) => {
  CollectionObject.find(coId).then(({ body }) => {
    const co = makeCollectionObject(body)

    state.collectionObject = co
    dispatch(ActionNames.LoadSoftValidation, co.globalId)

    BiologicalAssociation.where({
      subject_object_global_id: co.globalId,
      extend: ['origin_citation', 'object', 'biological_relationship']
    }).then(({ body }) => {
      state.biologicalAssociations = body
    })

    Container.for({ global_id: co.globalId, extend: ['container_items'] })
      .then(({ body }) => {
        state.container = body
      })
      .catch(() => {})

    if (co.repositoryId) {
      Repository.find(co.repositoryId).then(({ body }) => {
        state.repository = body
      })
    }

    if (co.currentRepositoryId) {
      Repository.find(co.currentRepositoryId).then(({ body }) => {
        state.currentRepository = body
      })
    }
  })

  dispatch(ActionNames.LoadBiocurations, coId)
  dispatch(ActionNames.LoadDwc, coId)
  dispatch(ActionNames.LoadTimeline, coId)

  CollectionObject.navigation(coId).then(({ body }) => {
    state.navigation = body
  })

  dispatch(ActionNames.LoadDepictions, { id: coId, page: 1 })
  dispatch(ActionNames.LoadConveyances, coId)

  TaxonDetermination.where({
    taxon_determination_object_id: [coId],
    taxon_determination_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    state.determinations = sortArray(body, 'position')
  })

  TypeMaterial.where({
    collection_object_id: coId,
    extend: ['roles', 'origin_citation']
  }).then(({ body }) => {
    state.typeMaterials = body
  })

  CollectingEvent.where({ collection_object_id: [coId] }).then(({ body }) => {
    const ce = body[0]

    if (ce) {
      state.collectingEvent = ce

      Georeference.where({ collecting_event_id: ce.id }).then(({ body }) => {
        state.georeferences = body
      })

      if (ce.geographic_area_id) {
        GeographicArea.find(ce.geographic_area_id, { embed: ['shape'] }).then(
          ({ body }) => {
            state.geographicArea = body
          }
        )
      }

      dispatch(ActionNames.LoadSoftValidation, ce.global_id)
      dispatch(ActionNames.LoadIdentifiersFor, {
        objectType: COLLECTING_EVENT,
        id: ce.id
      })
    }
  })

  dispatch(ActionNames.LoadIdentifiersFor, {
    objectType: COLLECTION_OBJECT,
    id: coId
  })
}
