import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, dispatch, state }) =>
  new Promise((resolve, reject) => {
    state.settings.saving = true
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveLabel)
      dispatch(ActionNames.SaveCollectionObject, state.collection_object).then((coCreated) => {
        const promises = []

        commit(MutationNames.SetCollectionObject, coCreated)
        commit(MutationNames.AddCollectionObject, coCreated)

        promises.push(dispatch(ActionNames.SaveTypeMaterial))
        promises.push(dispatch(ActionNames.SaveIdentifier, coCreated.id))
        promises.push(dispatch(ActionNames.SaveDeterminations))
        Promise.all(promises).then(() => {
          state.settings.saving = false
          state.settings.lastSave = Date.now()

          TW.workbench.alert.create('All records were successfully saved.', 'notice')
          resolve(true)
        }, () => {
          state.settings.saving = false
        })
      })
    }, () => {
      state.settings.saving = false
    })
  })
