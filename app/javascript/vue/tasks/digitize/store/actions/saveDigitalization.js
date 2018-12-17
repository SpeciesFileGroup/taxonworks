import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    state.settings.saving = true
    dispatch(ActionNames.SaveCollectionEvent).then(() => {
      dispatch(ActionNames.SaveLabel)
      dispatch(ActionNames.SaveCollectionObject).then((coCreated) => {
        dispatch(ActionNames.SaveDeterminations)
        dispatch(ActionNames.SaveTypeMaterial)
        dispatch(ActionNames.SaveIdentifier)
        if(!state.container) {
          if(state.collection_objects.length == 2) {
            dispatch(ActionNames.SaveContainer).then(() => {
              state.collection_objects.forEach(co => {
                dispatch(ActionNames.SaveContainerItem, co)
                state.settings.saving = false
              })
            })
          }
          else {
            state.settings.saving = false
          }
        }
        else {
          dispatch(ActionNames.SaveContainerItem, coCreated)
          state.settings.saving = false
        }        
      })
    })
  })
}