import ActionNames from './actionNames'

export default async ({ dispatch, state }, coObject) => {
  const promises = []

  try {
    state.settings.saving = true

    if (!state.container) {
      if (state.collection_objects.length === 1) {
        await dispatch(ActionNames.SaveContainer)

        promises.push(
          ...state.collection_objects.map((co) =>
            dispatch(ActionNames.SaveContainerItem, co)
          )
        )
      }
    } else {
      promises.push(dispatch(ActionNames.SaveContainerItem, coObject))
    }
  } catch (e) {
    throw e
  }

  state.settings.saving = false

  return Promise.all(promises)
}
