export default (state, georeference) => {
  const index = state.queueGeoreferences.findIndex(item => item.tmpId === georeference.tmpId)

  if (index > -1) {
    state.queueGeoreferences[index] = georeference
  } else {
    state.queueGeoreferences.push(georeference)
  }
}
