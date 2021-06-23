export default (state, status) => {
  const position = state.taxonStatusList.findIndex(item => item.id === status.id || item.type === status.type)

  if (position < 0) {
    state.taxonStatusList.push(status)
  } else {
    state.taxonStatusList[position] = status
  }
}
