export default (state, determination) => {
  const index = determination.id
    ? state.taxon_determinations.findIndex(d => d.id === determination.id)
    : state.taxon_determinations.findIndex(d => d.uuid === determination.uuid)

  if (index > -1) {
    state.taxon_determinations[index] = determination
  } else {
    state.taxon_determinations.push(determination)
  }
}
