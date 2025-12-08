import { AnatomicalPart } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'

export default ({ state }, coId) => {
  AnatomicalPart.childrenOf({
    parent_id: coId,
    parent_type: COLLECTION_OBJECT
  })
    .then((response) => {
      state.anatomicalParts = response.body
    })
    .catch(() => {})
}
