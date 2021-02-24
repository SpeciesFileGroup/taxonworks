export default function (state) {
  return state.matrixRowItems.sort((a, b) => {
    return a.position - b.position
  })
}
