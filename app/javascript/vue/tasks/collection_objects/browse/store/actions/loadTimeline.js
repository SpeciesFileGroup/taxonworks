import { CollectionObject } from 'routes/endpoints'

export default ({ state }, coId) =>
  CollectionObject.timeline(coId).then(({ body }) => {
    state.timeline = body
  })
