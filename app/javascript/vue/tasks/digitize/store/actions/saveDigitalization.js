import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    state.settings.saving = true
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveLabel)
      dispatch(ActionNames.SaveCollectionObject, state.collection_object).then((coCreated) => {
        commit(MutationNames.SetCollectionObject, coCreated)
        commit(MutationNames.AddCollectionObject, coCreated)
        let promises = []
        promises.push(dispatch(ActionNames.SaveTypeMaterial))
        promises.push(dispatch(ActionNames.SaveIdentifier))
        promises.push(dispatch(ActionNames.SaveDeterminations))
        Promise.all(promises).then(() => {
          state.settings.saving = false
          state.settings.lastSave = Date.now()
          TW.workbench.alert.create('All records were successfully saved.', 'notice')
          resolve(true)
        }, () => {
          // TW.workbench.alert.create('There was an error trying to save.', 'alert')
          state.settings.saving = false
        })
      })
    }, () => {
      state.settings.saving = false
    })
  })
}