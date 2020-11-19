import ajaxCall from 'helpers/ajaxCall'

const GetCollectionObject = (id) => ajaxCall('get', `/collection_objects/${id}.json`)

const GetImages = (params) => ajaxCall('get', '/images.json', { params: params })

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetUsers = () => ajaxCall('get', '/project_members.json')

export {
  GetCollectionObject,
  GetImages,
  GetUsers,
  GetOtu
}
