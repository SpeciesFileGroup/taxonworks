import ActionNames from './actionNames'

export default ({ dispatch, state }, coObject) =>
  new Promise((resolve,reject) => {
    if (!state.container) {
      if (state.collection_objects.length == 1) {
        dispatch(ActionNames.SaveContainer).then(() => {
          state.collection_objects.forEach(co => {
            dispatch(ActionNames.SaveContainerItem, co)
            state.settings.saving = false
            resolve(true)
          })
        })
      } else {
        state.settings.saving = false
        resolve(true)
      }
    } else {
      dispatch(ActionNames.SaveContainerItem, coObject)
      state.settings.saving = false
      resolve(true)
    }
  })
