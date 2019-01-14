import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    let determinations = state.taxon_determinations
    state.taxon_determinations = []

    let promises = []
    determinations.forEach((determination => {
      promises.push(dispatch(ActionNames.SaveDetermination, determination))
    }))

    Promise.all(promises).then(() => {
      resolve()
    }) 

  })
}