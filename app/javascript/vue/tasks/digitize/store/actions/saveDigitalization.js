import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveCollectionObject).then(() => {
        dispatch(ActionNames.SaveTypeMaterial).then(() => {
          dispatch(ActionNames.SaveIdentifier).then(() => {
            dispatch(ActionNames.SaveDetermination).then(() => {
              if(!state.container) {
                dispatch(ActionNames.SaveContainer).then(() => {
                  dispatch(ActionNames.SaveContainerItem)
                })
              }
              else {
                dispatch(ActionNames.SaveContainerItem)
              }
            })
          })
        })
      })
    })
  })
}