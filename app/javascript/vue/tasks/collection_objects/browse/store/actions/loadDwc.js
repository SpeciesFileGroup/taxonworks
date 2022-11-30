import { CollectionObject } from 'routes/endpoints'

export default ({ state }, coId) =>
  CollectionObject.dwca(coId).then(({ body }) => {
    state.dwc = body
  })
