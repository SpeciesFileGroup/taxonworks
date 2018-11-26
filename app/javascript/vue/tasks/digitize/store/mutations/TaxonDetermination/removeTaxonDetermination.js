export default function(state, id) {
  let index = state.taxon_determinations.findIndex((item) => {
    return item.id = id
  })
  state.taxon_determinations.slice(index, 1)
}