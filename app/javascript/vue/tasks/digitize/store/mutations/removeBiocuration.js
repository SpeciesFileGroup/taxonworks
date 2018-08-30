export default function(state, value) {
  let position = state.biocurations.findIndex(item => {
    return item.id == value
  })
  if(position > -1) {
    state.biocurations.splice(position,1)
  }
}