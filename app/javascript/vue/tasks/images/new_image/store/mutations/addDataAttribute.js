import { addToArray } from '@/helpers/arrays'

export default (state, dataAttribute) => {
  addToArray(state.data_attributes, dataAttribute, {
    property: 'controlled_vocabulary_term_id'
  })
}
