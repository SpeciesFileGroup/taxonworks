import { Depiction } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'
import { getPagination } from '@/helpers'

export default ({ state }, { id, page = 1 }) => {
  Depiction.where({
    depiction_object_id: [id],
    depiction_object_type: COLLECTION_OBJECT,
    page
  }).then((response) => {
    state.depictions.list = response.body
    state.depictions.pagination = getPagination(response)
  })
}
