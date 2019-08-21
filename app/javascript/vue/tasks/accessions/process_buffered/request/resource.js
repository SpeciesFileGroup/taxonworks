import ajaxCall from 'helpers/ajaxCall.js'

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

const UpdateCollectingEvent = (data) => {
  return ajaxCall('patch', `/collecting_events/${data.id}`, { collecting_event: data })
}

const UpdateCollectionObject = (data) => {
  return ajaxCall('patch', `/collection_objects/${data.id}`, { collection_object: data })
}

export {
  GetCollectingEvent,
  GetCollectionObject,
  GetDepiction,
  GetDepictionByCOId,
  UpdateCollectingEvent,
  UpdateCollectionObject
}
