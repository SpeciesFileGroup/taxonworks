import { CollectionObject } from '@/routes/endpoints'

export default ({ state }, coId) =>
  CollectionObject.dwcCompact(coId).then(({ body }) => {
    state.dwc = body
  })
