import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations';

export default function ({ commit, dispatch, state }, coId) {
  return new Promise((resolve, reject) => {
    state.settings.loading = true
    dispatch(ActionNames.GetCollectionObject, coId).then(coObject => {
      const promises = []

      dispatch(ActionNames.LoadContainer, coObject.global_id)
      if (coObject.collecting_event_id)
        promises.push(dispatch(ActionNames.GetCollectionEvent, coObject.collecting_event_id))

      promises.push(dispatch(ActionNames.GetIdentifiers, coId).then(response => {
        if (response.length) {
          commit(MutationNames.SetIdentifier, response[0])
          dispatch(ActionNames.GetNamespace, response[0].namespace_id)
        }
      }))

      promises.push(dispatch(ActionNames.GetTypeMaterial, coId))
      promises.push(dispatch(ActionNames.GetLabels, coObject.collecting_event_id))
      promises.push(dispatch(ActionNames.GetTaxonDeterminations, coId))
      commit(MutationNames.AddCollectionObject, coObject)

      Promise.all(promises).then(() => {
        state.settings.loading = false
        state.settings.lastChange = 0
        resolve()
      }, () => {
        state.settings.loading = false
        reject()
      })
    }, error => {
      state.settings.loading = false
      reject(error)
    })
  })
}