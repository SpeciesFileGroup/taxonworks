import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations';

export default function ({ commit, dispatch, state }, coId) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.GetCollectionObject, coId).then((coObject) => {
      if(coObject.collecting_event_id)
        dispatch(ActionNames.GetCollectionEvent, coObject.collecting_event_id)

      dispatch(ActionNames.GetIdentifiers, coId).then(response => {
        if(response.length) {
          commit(MutationNames.SetIdentifier, response[0])
          dispatch(ActionNames.GetNamespace, response[0].namespace_id)
        }
      })
      
      dispatch(ActionNames.GetTypeMaterial, coId)
      dispatch(ActionNames.GetTaxonDeterminations, coId)
      commit(MutationNames.AddCollectionObject, coObject)
    })
  })
}