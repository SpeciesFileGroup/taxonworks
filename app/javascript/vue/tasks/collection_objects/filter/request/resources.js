import ajaxCall from 'helpers/ajaxCall'

const GetCollectionObjects = (params) => {
  return ajaxCall('get', '/collection_objects.json', { params: params })
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

export {
  GetCollectionObjects,
  GetUsers
}
