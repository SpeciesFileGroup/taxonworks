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
  return AjaxCall('get', `/collection_objects/${id}/dwc_verbose`)
}

const CreateTag = (data) => {
  return AjaxCall('post', `/tags.json`, { tags: data })
}

export {
  GetCollectionObject,
  GetCollectionObjectById,
  GetCollectingEvent,
  CreateTag,
  GetDWC
}