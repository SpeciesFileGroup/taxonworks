import ajaxCall from 'helpers/ajaxCall.js'

const CreateCollectingEvent = (data) => {
  return ajaxCall('post', `/collecting_events.json`, { collecting_event: data })
}

const GetCollectingEvent = (id) => {
  return ajaxCall('get', `/collecting_events/${id}`)
}

const GetCollectionObject = (id) => {
  return ajaxCall('get', `/collection_objects/${id}`)
}

const GetDepiction = (id) => {
  return ajaxCall('get', `/depictions/${id}`)
}

const GetDepictionByCOId = (id) => {
  return ajaxCall('get', `/depictions.json`, { params: { depiction_object_type: 'CollectionObject', depiction_object_id: id } })
}

const GetGeographicSmartSelector = () => {
  return ajaxCall('get', `/geographic_areas/select_options?target=CollectingEvent`)
}

const GetNearbyCOFromDepictionSqedId = (id) => {
  return ajaxCall('get', `/sqed_depictions/${id}/nearby.json`)
}

const UpdateCollectingEvent = (data) => {
  return ajaxCall('patch', `/collecting_events/${data.id}`, { collecting_event: data })
}

const UpdateCollectionObject = (data) => {
  return ajaxCall('patch', `/collection_objects/${data.id}`, { collection_object: data })
}

export {
  CreateCollectingEvent,
  GetCollectingEvent,
  GetCollectionObject,
  GetGeographicSmartSelector,
  GetNearbyCOFromDepictionSqedId,
  GetDepiction,
  GetDepictionByCOId,
  UpdateCollectingEvent,
  UpdateCollectionObject
}
