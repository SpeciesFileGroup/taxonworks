import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { EVENT_SMART_SELECTOR_UPDATE } from 'constants/index.js'
import { CollectionObject } from 'routes/endpoints'

const updateSmartSelectors = () => {
  const event = new CustomEvent(EVENT_SMART_SELECTOR_UPDATE)
  document.dispatchEvent(event)
}

export default ({ commit, dispatch, state }) =>
  new Promise((resolve, reject) => {
    state.settings.saving = true
    dispatch(ActionNames.SaveCollectingEvent).then(() => {
      dispatch(ActionNames.SaveLabel)
      dispatch(ActionNames.SaveCollectionObject, state.collection_object).then((coCreated) => {
        commit(MutationNames.SetCollectionObject, coCreated)
        commit(MutationNames.AddCollectionObject, coCreated)

        const actions = [
          dispatch(ActionNames.SaveTypeMaterial),
          dispatch(ActionNames.SaveCOCitations),
          dispatch(ActionNames.SaveIdentifier, coCreated.id),
          dispatch(ActionNames.SaveDeterminations),
          dispatch(ActionNames.SaveBiologicalAssociations)
        ]

        Promise.allSettled(actions).then(_ => {
          state.settings.lastSave = Date.now()

          dispatch(ActionNames.LoadSoftValidations)

          CollectionObject.find(state.collection_object.id).then(({ body }) => {
            state.collection_object.object_tag = body.object_tag
          })

          TW.workbench.alert.create('All records were successfully saved.', 'notice')
          resolve(true)
        }).finally(() => {
          updateSmartSelectors()
          state.settings.saving = false
        })
      }).catch(() => {
        state.settings.saving = false
      })
    }).catch(_ => {
      state.settings.saving = false
    })
  })
