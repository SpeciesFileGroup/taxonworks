export default function (state) {
  return state.matrixColumnItems.sort((a, b) => {
    return a.position - b.position
  })
}
