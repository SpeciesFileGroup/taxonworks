import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }, coId) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.GetCollectionObject, coId).then(() => {
      //dispatch(ActionNames.GetCollectingEvent)
      //dispatch(ActionNames.GetIdentifiers)
      dispatch(ActionNames.GetTypeMaterial, coId)
      dispatch(ActionNames.GetTaxonDeterminations, coId)
    })
  })
}