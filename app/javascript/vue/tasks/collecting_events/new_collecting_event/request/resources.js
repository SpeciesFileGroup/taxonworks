import ajaxCall from 'helpers/ajaxCall'

const CreateCollectingEvent = (ce) => ajaxCall('post', '/collecting_events.json', { collecting_events: ce })

const GetCollectingEvent = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const GetGeographicArea = (id) => ajaxCall('get', `/geographic_areas/${id}.json`)

const GetGeographicAreaByCoords = (lat, long) => ajaxCall('get', `/geographic_areas/by_lat_long?latitude=${lat}&longitude=${long}`)

const GetRecentCollectingEvents = () => ajaxCall('get', '/collecting_events.json?per=10&recent=true')

const UpdateCollectingEvent = (ce) => ajaxCall('patch', `/collecting_events/${ce.id}`, { collecting_events: ce })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const LoadSoftValidation = (globalId) => ajaxCall('get', `/soft_validations/validate?global_id=${globalId}`)

export {
  CreateCollectingEvent,
  GetCollectingEvent,
  GetGeographicArea,
  GetRecentCollectingEvents,
  GetUserPreferences,
  GetGeographicAreaByCoords,
  LoadSoftValidation,
  UpdateCollectingEvent,
  UpdateUserPreferences
}
