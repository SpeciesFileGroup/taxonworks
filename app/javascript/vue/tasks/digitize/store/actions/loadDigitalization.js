import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.GetCollectionObject).then(() => {
      dispatch(ActionNames.GetCollectingEvent)
      dispatch(ActionNames.GetIdentifiers)
      dispatch(ActionNames.GetTypeMaterial)
      dispatch(ActionNames.SaveDetermination)
    })
  })
}