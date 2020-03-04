import AjaxCall from 'helpers/ajaxCall'

const GetCollectionObject = (params) => {
  return AjaxCall('get', `/collection_objects.json`, { params: params })
}

const GetCollectionObjectById = (id) => {
  return AjaxCall('get', `/collection_objects/${id}.json`)
}

export {
  GetCollectionObject,
  GetCollectionObjectById
}