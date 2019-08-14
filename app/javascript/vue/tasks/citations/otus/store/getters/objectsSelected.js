export default function (state) {
  if (state.selected.otu == undefined || state.selected.source == undefined) {
    return true
  } else {
    return false
  }
}
