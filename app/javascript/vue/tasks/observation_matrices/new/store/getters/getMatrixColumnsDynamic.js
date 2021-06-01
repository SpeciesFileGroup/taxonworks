export default function (state) {
  return state.matrixColumnDynamicItems.sort((a, b) => {
    return a.position - b.position
  })
}
