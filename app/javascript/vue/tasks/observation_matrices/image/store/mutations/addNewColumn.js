export default (state, value) => {
  const column = {
    id: value.id,
    description: value.description,
    name: value.name,
    weight: value.weight,
    type: value.type,
    index: state.observationColumns.length
  }

  state.observationColumns.push(column)
  state.observationRows.forEach(row => {
    row.depictions.push([])
  })
}
