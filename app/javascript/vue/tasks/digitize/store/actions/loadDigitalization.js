import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import {
  COLLECTION_OBJECT,
  CONTAINER,
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants/index.js'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'

export default ({ commit, dispatch, state }, coId) =>
  new Promise((resolve, reject) => {
    const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
    const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
    const collectingEventStore = useCollectingEventStore()
    const determinationStore = useTaxonDeterminationStore()

    state.settings.loading = true
    dispatch(ActionNames.GetCollectionObject, coId)
      .then(({ body }) => {
        const coObject = body
        const promises = []

        dispatch(ActionNames.LoadContainer, coObject.global_id)
          .then(({ body }) => {
            promises.push(
              catalogNumber.load({
                objectId: body.id,
                objectType: CONTAINER
              }),
              recordNumber.load({
                objectId: body.id,
                objectType: CONTAINER
              })
            )
          })
          .catch(() => {
            promises.push(
              catalogNumber.load({
                objectId: coId,
                objectType: COLLECTION_OBJECT
              }),
              recordNumber.load({
                objectId: coId,
                objectType: COLLECTION_OBJECT
              })
            )
          })

        if (coObject.collecting_event_id) {
          collectingEventStore.load(coObject.collecting_event_id)
        }

        promises.push(
          determinationStore.load({
            objectId: coId,
            objectType: COLLECTION_OBJECT
          })
        )

        promises.push(dispatch(ActionNames.LoadTypeSpecimens, coId))
        promises.push(dispatch(ActionNames.GetCOCitations, coId))
        promises.push(dispatch(ActionNames.LoadBiologicalAssociations))

        commit(MutationNames.AddCollectionObject, coObject)

        Promise.allSettled(promises).then(() => {
          dispatch(ActionNames.LoadSoftValidations)
          state.settings.lastChange = 0
          state.settings.loading = false
          resolve()
        })
      })
      .catch((error) => {
        reject(error)
        state.settings.loading = false
      })
  })
