import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import {
  COLLECTION_OBJECT,
  CONTAINER
} from 'constants/index.js'

export default ({ commit, dispatch, state }, coId) =>
  new Promise((resolve, reject) => {
    state.settings.loading = true
    dispatch(ActionNames.GetCollectionObject, coId).then(coObject => {
      const promises = []

      dispatch(ActionNames.LoadContainer, coObject.global_id).then(response => {
        promises.push(dispatch(ActionNames.GetIdentifiers, { id: response.body.id, type: CONTAINER }).then(response => {
          if (response.length) {
            commit(MutationNames.SetIdentifier, response[0])
            dispatch(ActionNames.GetNamespace, response[0].namespace_id)
          }
        }))
      }).catch(_ => {
        promises.push(dispatch(ActionNames.GetIdentifiers, { id: coId, type: COLLECTION_OBJECT }).then(response => {
          if (response.length) {
            commit(MutationNames.SetIdentifier, response[0])
            dispatch(ActionNames.GetNamespace, response[0].namespace_id)
          }
        }))
      })

      if (coObject.collecting_event_id) {
        promises.push(dispatch(ActionNames.GetCollectingEvent, coObject.collecting_event_id))
        promises.push(dispatch(ActionNames.LoadGeoreferences, coObject.collecting_event_id))
        promises.push(dispatch(ActionNames.GetLabels, coObject.collecting_event_id))
      } else {
        dispatch(ActionNames.NewLabel)
      }

      promises.push(dispatch(ActionNames.LoadTypeSpecimens, coId))
      promises.push(dispatch(ActionNames.GetCOCitations, coId))
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
