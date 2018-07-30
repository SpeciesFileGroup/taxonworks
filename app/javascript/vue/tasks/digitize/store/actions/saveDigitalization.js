import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, rejected) => {
    dispatch(ActionNames.SaveCollectionObject).then(respone => {
      dispatch(ActionNames.SaveIdentifier)
      dispatch(ActionNames.SaveCollectionEvent)
      dispatch(ActionNames.SaveTypeMaterial)
    })
  }, (response) => {
    return rejected(response)
  })
}