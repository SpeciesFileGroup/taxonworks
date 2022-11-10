import { CollectingEvent } from 'routes/endpoints'

export default ({ state }, { collectingEventId, payload }) =>
  CollectingEvent.update(collectingEventId, { collecting_event: payload }).then(({ body }) => {
    state.collectingEvent = body
  })
