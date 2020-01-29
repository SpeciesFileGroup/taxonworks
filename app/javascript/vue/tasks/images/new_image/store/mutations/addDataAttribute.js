export default function(state, value) {
  let index = state.data_attributes.findIndex(item => {
    return item.controlled_vocabulary_term_id == value.controlled_vocabulary_term_id
  })
  if(index > -1) {
    state.data_attributes[index] = value
  }
  else {
    state.data_attributes.push(value)
  }
}