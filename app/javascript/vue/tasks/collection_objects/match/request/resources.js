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

const CreateDetermination = (data) => {
  return AjaxCall('post', `/taxon_determinations.json`, { taxon_determination: data })
}

const UpdateCollectionObject = (id, co) => {
  return AjaxCall('patch', `/collection_objects/${id}.json`, { collection_object: co })
}

const UpdateLoan = (id, data) => {
  return AjaxCall('patch', `/loans/${id}.json`, { loan: data })
}

export {
  CreateDetermination,
  CreateTag,
  GetCollectingEvent,
  GetCollectionObject,
  GetCollectionObjectById,
  GetDWC,
  UpdateCollectionObject,
  UpdateLoan
}