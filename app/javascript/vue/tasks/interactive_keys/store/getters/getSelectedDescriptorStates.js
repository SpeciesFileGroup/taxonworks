export default (state) => {
  const used = state.observationMatrix.list_of_descriptors.filter((d) => d.status === 'used')
  let selected = []
  used.forEach((d) => {
    switch(d.type) {
      case 'Descriptor::Qualitative':
        selected.push({
          type: 'Qualitative',
          state: d.name,
          value: d.states.filter((s) => s.status == 'used')[0]?.name || '',
          unused: d.states.filter((s) => s.status != 'used').map((s) => s.name)
        })
        break

      case 'Descriptor::Sample':
        selected.push({
          type: 'Sample',
          state: d.name,
          value: state.observationMatrix.selected_descriptors_hash[d.id][0],
          unused: []
        })
        break

      case 'Descriptor::PresenceAbsence':
        const value = state.observationMatrix.selected_descriptors_hash[d.id][0]
        selected.push({
          type: 'PresenceAbsence',
          state: d.name,
          value:  value ? 'present' : 'absent',
          unused: [value ? 'absent' : 'present']
        })
        break

      case 'Descriptor::Continuous':
        selected.push({
          type: 'Continuous',
          state: d.name,
          value: state.observationMatrix.selected_descriptors_hash[d.id][0],
          unused: []
        })
        break

      default:
        selected.push({
          type: `Unsupported type '${d.type}`,
          state: 'Unsupported state',
          value: 'Unsupported value',
          unused: []
        })
    }
  })

  return selected
}
