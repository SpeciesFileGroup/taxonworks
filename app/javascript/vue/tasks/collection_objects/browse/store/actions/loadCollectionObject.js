import {
  CollectionObject,
  CollectingEvent,
  Container,
  Georeference,
  TaxonDetermination,
  BiologicalAssociation,
  TypeMaterial
} from 'routes/endpoints'
import { makeCollectionObject } from 'adapters/index.js'
import {
  COLLECTION_OBJECT,
  COLLECTING_EVENT
} from 'constants/index.js'
import ActionNames from './actionNames'

export default ({ state, dispatch }, coId) => {
  CollectionObject.find(coId).then(({ body }) => {
    const co = makeCollectionObject(body)

    state.collectionObject = co
    dispatch(ActionNames.LoadSoftValidation, co.globalId)

    BiologicalAssociation
      .where({
        subject_global_id: co.globalId,
        extend: ['origin_citation', 'object', 'biological_relationship']
      })
      .then(({ body }) => { state.biologicalAssociations = body })

    Container
      .for(co.globalId)
      .then(({ body }) => {
        state.container = body
      })
  })

  dispatch(ActionNames.LoadBiocurations, coId)

  CollectionObject.dwca(coId).then(({ body }) => {
    state.dwc = body
  })

  CollectionObject.navigation(coId).then(({ body }) => {
    state.navigation = body
  })

  CollectionObject.depictions(coId).then(({ body }) => {
    state.depictions = body
  })

  CollectionObject
    .timeline(coId)
    .then(({ body }) => { state.timeline = body })

  TaxonDetermination
    .where({ biological_collection_object_ids: [coId] })
    .then(({ body }) => { state.determinations = body })

  TypeMaterial
    .where({
      collection_object_id: coId,
      extend: ['roles', 'origin_citation']
    })
    .then(({ body }) => { state.typeMaterials = body })

  CollectingEvent.where({ collection_object_id: [coId] }).then(({ body }) => {
    const ce = body[0]

    if (ce) {
      state.collectingEvent = ce

      Georeference.where({ collecting_event_id: ce.id }).then(({ body }) => {
        state.georeferences = body
      })

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
