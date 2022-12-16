import { CollectionObject } from 'routes/endpoints'

export default function () {
  const payload = {
    collection_object: {
      preparation_type_id: this.preparationTypeId,
      collecting_event_id: this.createdCE?.id,
      total: 1
    }
  }

  return CollectionObject.create(payload)
}
