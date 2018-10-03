import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveLabel)
      dispatch(ActionNames.SaveCollectionObject).then((coCreated) => {
        dispatch(ActionNames.SaveDetermination)
        dispatch(ActionNames.SaveTypeMaterial)
        dispatch(ActionNames.SaveIdentifier)
        dispatch(ActionNames.SaveDetermination)
        if(!state.container) {
          if(state.collection_objects.length == 2) {
            dispatch(ActionNames.SaveContainer).then(() => {
              state.collection_objects.forEach(co => {
                dispatch(ActionNames.SaveContainerItem, co)
              })
            })
          }
        }
        else {
          dispatch(ActionNames.SaveContainerItem, coCreated)
        }        
      })
    })
  })
}