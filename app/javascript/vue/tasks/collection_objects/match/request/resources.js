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

const GetDWC = (id) => {
  return AjaxCall('get', `/collection_objects/${id}/dwc_verbose?rebuild=true`)
}

const CreateTag = (data) => {
  return AjaxCall('post', `/tags.json`, { tag: data })
}

export {
  GetCollectionObject,
  GetCollectionObjectById,
  GetCollectingEvent,
  CreateTag,
  GetDWC
}