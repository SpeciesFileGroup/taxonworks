import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { EVENT_SMART_SELECTOR_UPDATE } from '@/constants/index.js'
import { CollectionObject } from '@/routes/endpoints'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import {
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  COLLECTION_OBJECT,
  CONTAINER
} from '@/constants/index.js'

const updateSmartSelectors = () => {
  const event = new CustomEvent(EVENT_SMART_SELECTOR_UPDATE)
  document.dispatchEvent(event)
}

export default ({ commit, dispatch, state }, { resetAfter = false } = {}) =>
  new Promise((resolve, reject) => {
    const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
    const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
    const determinationStore = useTaxonDeterminationStore()

    state.settings.saving = true
    dispatch(ActionNames.SaveCollectingEvent)
      .then(() => {
        dispatch(ActionNames.SaveLabel)
        dispatch(ActionNames.SaveCollectionObject, state.collection_object)
          .then(({ body }) => {
            const coCreated = body
            const payload = {
              objectId: state.container ? state.container.id : coCreated.id,
              objectType: state.container ? CONTAINER : COLLECTION_OBJECT
            }

            commit(MutationNames.SetCollectionObject, coCreated)
            commit(MutationNames.AddCollectionObject, coCreated)

            const actions = [
              dispatch(ActionNames.SaveTypeMaterial),
              dispatch(ActionNames.SaveCOCitations),
              dispatch(ActionNames.SaveBiologicalAssociations),
              recordNumber.save(payload),
              catalogNumber.save(payload),
              determinationStore.save({
                objectId: coCreated.id,
                objectType: COLLECTION_OBJECT
              })
            ]

            Promise.allSettled(actions)
              .then(async (promises) => {
                const allSaved = promises.every(
                  (item) => item.status == 'fulfilled'
                )

                if (resetAfter && allSaved) {
                  dispatch(ActionNames.ResetWithDefault)
                } else {
                  await dispatch(ActionNames.LoadSoftValidations)
                  await CollectionObject.find(state.collection_object.id).then(
                    ({ body }) => {
                      state.collection_object.object_tag = body.object_tag
                    }
                  )

                  state.settings.lastSave = Date.now()
                }

                if (allSaved) {
                  TW.workbench.alert.create(
                    'All records were successfully saved.',
                    'notice'
                  )
                }

                resolve(true)
              })
              .finally(() => {
                updateSmartSelectors()
                state.settings.saving = false
              })
          })
          .catch(() => {
            state.settings.saving = false
          })
      })
      .catch(() => {
        state.settings.saving = false
      })
  })
