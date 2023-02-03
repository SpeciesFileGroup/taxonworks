import { CollectingEvent } from 'routes/endpoints'

export default function () {
  const payload = {
    ...this.collectingEvent,
    geographic_area_id: this.geographicArea?.id
  }

  return CollectingEvent
    .create({ collecting_event: payload })
    .then(({ body }) => {
      this.createdCE = body
    })
}
