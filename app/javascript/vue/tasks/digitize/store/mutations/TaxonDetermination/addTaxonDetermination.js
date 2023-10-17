import { addToArray } from '@/helpers'

export default (state, determination) => {
  const property = determination.id ? 'id' : 'uuid'

  addToArray(state.taxon_determinations, determination, {
    property,
    prepend: true
  })
}
