import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import {
  COLLECTION_OBJECT,
  CONTAINER,
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants/index.js'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations.js'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'

export default ({ commit, dispatch, state }, coId) =>
  new Promise((resolve, reject) => {
    const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
    const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
    const collectingEventStore = useCollectingEventStore()
    const determinationStore = useTaxonDeterminationStore()
    const biologicalAssociationStore = useBiologicalAssociationStore()
    const biocurationStore = useBiocurationStore()

    state.settings.loading = true
    dispatch(ActionNames.GetCollectionObject, coId)
      .then(({ body }) => {
        const coObject = body
        const promises = []
        const payload = {
          objectId: body.id,
          objectType: COLLECTION_OBJECT
        }

        dispatch(ActionNames.LoadContainer, coObject.global_id)
          .then((container) => {
            promises.push(
              catalogNumber.load({
                objectId: container.id,
                objectType: CONTAINER
              }),
              recordNumber.load({
                objectId: container.id,
                objectType: CONTAINER
              })
            )
          })
          .catch(() => {
            promises.push(
              catalogNumber.load(payload),
              recordNumber.load(payload)
            )
          })

        if (coObject.collecting_event_id) {
          collectingEventStore.load(coObject.collecting_event_id)
        }

        promises.push(
          determinationStore.load(payload),
          biologicalAssociationStore.load(payload),
          biocurationStore.load(payload)
        )

        promises.push(dispatch(ActionNames.LoadTypeSpecimens, coId))
        promises.push(dispatch(ActionNames.GetCOCitations, coId))

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
