import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations';

export default function ({ commit, dispatch, state }, coId) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.GetCollectionObject, coId).then((coObject) => {
      if(coObject.collecting_event_id)
        dispatch(ActionNames.GetCollectionEvent, coObject.collecting_event_id)
      //dispatch(ActionNames.GetIdentifiers)
      dispatch(ActionNames.GetTypeMaterial, coId)
      dispatch(ActionNames.GetTaxonDeterminations, coId)
      commit(MutationNames.AddCollectionObject, coObject)
    })
  })
}