import ajaxCall from 'helpers/ajaxCall'

const GetCollectionObjects = (params) => {
  return ajaxCall('get', '/collection_objects.json', { params: params })
}

export {
  GetCollectionObjects
}