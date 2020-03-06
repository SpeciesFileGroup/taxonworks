import AjaxCall from 'helpers/ajaxCall'

const GetCollectionObject = (params) => {
  return AjaxCall('get', `/collection_objects.json`, { params: params })
}

const GetCollectionObjectById = (id) => {
  return AjaxCall('get', `/collection_objects/${id}.json`)
}

const GetCollectingEvent = (id) => {
  return AjaxCall('get', `/collecting_events/${id}.json`)
}

export {
  GetCollectionObject,
  GetCollectionObjectById,
  GetCollectingEvent
}