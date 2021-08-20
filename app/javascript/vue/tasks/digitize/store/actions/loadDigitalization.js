import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, dispatch, state }, coId) => 
  new Promise((resolve, reject) => {
    state.settings.loading = true
    dispatch(ActionNames.GetCollectionObject, coId).then(coObject => {
      const promises = []

      dispatch(ActionNames.LoadContainer, coObject.global_id).then(response => {
        promises.push(dispatch(ActionNames.GetIdentifiers, { id: response.body.id, type: 'Container' }).then(response => {
          if (response.length) {
            commit(MutationNames.SetIdentifier, response[0])
            dispatch(ActionNames.GetNamespace, response[0].namespace_id)
          }
        }))
      }).catch(_ => {
        promises.push(dispatch(ActionNames.GetIdentifiers, { id: coId, type: 'CollectionObject' }).then(response => {
          if (response.length) {
            commit(MutationNames.SetIdentifier, response[0])
            dispatch(ActionNames.GetNamespace, response[0].namespace_id)
          }
        }))
      })

      if (coObject.collecting_event_id) {
        promises.push(dispatch(ActionNames.GetCollectionEvent, coObject.collecting_event_id))
        promises.push(dispatch(ActionNames.LoadGeoreferences, coObject.collecting_event_id))
      }

      promises.push(dispatch(ActionNames.GetTypeMaterial, coId))
      promises.push(dispatch(ActionNames.GetCOCitations, coId))
      promises.push(dispatch(ActionNames.GetLabels, coObject.collecting_event_id))
      promises.push(dispatch(ActionNames.GetTaxonDeterminations, coId))
      promises.push(dispatch(ActionNames.LoadBiologicalAssociations))
      commit(MutationNames.AddCollectionObject, coObject)

      Promise.allSettled(promises).then(() => {
        dispatch(ActionNames.LoadSoftValidations)
        state.settings.lastChange = 0
        resolve()
      })
    }).catch(error => {
      reject(error)
    }).finally(() => {
      state.settings.loading = false
    })
  })
