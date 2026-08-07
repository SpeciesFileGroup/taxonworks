import { removeFromArray } from '@/helpers/arrays'

export default (state, dataAttribute) => {
  removeFromArray(state.data_attributes, dataAttribute, {
    property: 'controlled_vocabulary_term_id'
  })
}
