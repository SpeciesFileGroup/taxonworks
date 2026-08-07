export default (state, payload) => {
  const {
    type,
    list
  } = payload

  state.citations[type] = list
}
