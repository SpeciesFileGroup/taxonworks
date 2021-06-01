export default function (state) {
  return state.matrixRowDynamicItems.sort((a, b) => {
    return a.position - b.position
  })
}
