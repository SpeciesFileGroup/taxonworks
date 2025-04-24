import { COLLECTION_OBJECT } from '@/constants'
import { Conveyance } from '@/routes/endpoints'

export default ({ state }, id) => {
  Conveyance.where({
    conveyance_object_id: id,
    conveyance_object_type: COLLECTION_OBJECT,
    per: 500
  })
    .then(({ body }) => {
      state.conveyances = body
    })
    .catch(() => {})
}
