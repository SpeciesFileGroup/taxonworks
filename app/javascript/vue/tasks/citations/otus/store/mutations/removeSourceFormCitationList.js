export default function (state, id) {
  var position = state.source_citations.findIndex(item => {
    if (id === item.id) {
      return true
    }
  })
  if (position >= 0) {
    if (state.selected.citation.id == state.source_citations[position].id) {
      state.selected.otu = undefined
      state.selected.source = undefined
      state.selected.citation = undefined
      state.citations = []
      state.source_citations = [],
      state.otu_citations = []
    }
    state.source_citations.splice(position, 1)
  }
}
