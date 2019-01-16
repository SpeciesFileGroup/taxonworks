import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }, coId) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.GetCollectionObject, coId).then((coObject) => {
      if(coObject.collecting_event_id)
        dispatch(ActionNames.GetCollectionEvent, coObject.collecting_event_id)
      //dispatch(ActionNames.GetIdentifiers)
      dispatch(ActionNames.GetTypeMaterial, coId)
      dispatch(ActionNames.GetTaxonDeterminations, coId)
    })
  })
}