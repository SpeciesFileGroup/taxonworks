import ajaxCall from 'helpers/ajaxCall'

const GetCollectingEvent = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const GetImage = (id) => ajaxCall('get', `/images/${id}.json`)

const GetRepository = (id) => ajaxCall('get', `/repositories/${id}.json`)

const GetSledImage = (id) => ajaxCall('get', `/sled_images/${id}.json`)

const GetPreparationTypes = () => ajaxCall('get', '/preparation_types.json')

const UpdateSledImage = (id, data) => ajaxCall('patch', `/sled_images/${id}.json`, data)

const CreateSledImage = (data) => ajaxCall('post', '/sled_images.json', data)

const NukeSledImage = (id) => ajaxCall('delete', `/sled_images/${id}.json`, { params: { nuke: 'nuke' } })

const NavigationSled = (globalId) => ajaxCall('get', `/metadata/object_navigation/${encodeURIComponent(globalId)}`)

const Report = (id) => ajaxCall('get', '/collection_objects/report.json', { params: { sled_image_id: id } })

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

export {
  GetImage,
  GetSledImage,
  GetCollectingEvent,
  GetRepository,
  UpdateSledImage,
  NukeSledImage,
  CreateSledImage,
  NavigationSled,
  Report,
  GetUserPreferences,
  GetPreparationTypes,
  UpdateUserPreferences
}
