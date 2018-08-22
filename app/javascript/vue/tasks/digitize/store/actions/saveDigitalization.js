import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveCollectionObject).then(() => {
        if(!state.container) {
          dispatch(ActionNames.SaveContainer).then(() => {
            dispatch(ActionNames.SaveContainerItem)
          })
        }
        else {
          dispatch(ActionNames.SaveContainerItem)
        }
        dispatch(ActionNames.SaveIdentifier)
        dispatch(ActionNames.SaveTypeMaterial)
        dispatch(ActionNames.SaveDetermination)
      })
    })
  })
}