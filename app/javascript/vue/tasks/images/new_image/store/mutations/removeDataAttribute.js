import { removeFromArray } from '@/helpers/arrays'

export default (state, dataAttribute) => {
  removeFromArray(
    state.data_attributes,
    dataAttribute,
    'controlled_vocabulary_term_id'
  )
}
