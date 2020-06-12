import ajaxCall from 'helpers/ajaxCall'

const CreateCollectingEvent = (ce) => {
  return ajaxCall('post', '/collecting_events.json', { collecting_events: ce })
}

const GetCollectingEvent = (id) => {
  return ajaxCall('get', `/collecting_events/${id}.json`)
}

const GetGeographicArea = (id) => {
  return ajaxCall('get', `/geographic_areas/${id}.json`)
}

const GetGeographicAreaByCoords = (lat, long) => {
  return ajaxCall('get', `/geographic_areas/by_lat_long?latitude=${lat}&longitude=${long}`)
}

const GetRecentCollectingEvents = () => {
  return ajaxCall('get', '/collecting_events.json?per=10&recent=true')
}

const UpdateCollectingEvent = (ce) => {
  return ajaxCall('patch', `/collecting_events/${ce.id}`, { collecting_events: ce })
}

const UpdateUserPreferences = (id, data) => {
  return ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })
}

const GetUserPreferences = () => {
  return ajaxCall('get', '/preferences.json')
}

const LoadSoftValidation = (globalId) => {
  return ajaxCall('get', `/soft_validations/validate?global_id=${globalId}`)
}

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
