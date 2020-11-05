import ajaxCall from 'helpers/ajaxCall'

const GetImages = (params) => ajaxCall('get', '/images.json', { params: params })

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetUsers = () => ajaxCall('get', '/project_members.json')

export {
  GetImages,
  GetUsers,
  GetOtu
}
