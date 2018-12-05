export default function ({ commit, state }, args) {
  console.log("Entra")
  return state.request.createClone(args)
    .then(responseData => {
      console.log(responseData)
    })
}
