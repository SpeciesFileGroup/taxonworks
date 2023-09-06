import { CollectionObject } from '@/routes/endpoints'

export default ({ state }, coId) =>
  CollectionObject.dwcVerbose(coId).then(({ body }) => {
    state.dwc = body
  })
