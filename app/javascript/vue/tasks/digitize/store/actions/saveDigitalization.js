import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveCollectionObject).then(() => {
        dispatch(ActionNames.SaveContainer)
        dispatch(ActionNames.SaveIdentifier)
        dispatch(ActionNames.SaveTypeMaterial)
        dispatch(ActionNames.SaveDetermination)
      })
    })
  })
}