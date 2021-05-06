import ajaxCall from 'helpers/ajaxCall'

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const GetRecentCollectingEvents = () => ajaxCall('get', '/collecting_events.json', { params: { per: 10, recent: true } })

const GetSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const GetTripCodeByCE = (ceId) => ajaxCall('get', `/identifiers.json?identifier_object_type=CollectingEvent&identifier_object_id=${ceId}&type=Identifier::Local::TripCode`)

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const LoadSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const NavigateCollectingEvents = (id) => ajaxCall('get', `/collecting_events/${id}/navigation`)

const ParseVerbatim = (label) => ajaxCall('get', '/collecting_events/parse_verbatim_label', { params: { verbatim_label: label } })

const RemoveIdentifier = (id) => ajaxCall('delete', `/identifiers/${id}.json`)

const UpdateCollectingEvent = (ce) => ajaxCall('patch', `/collecting_events/${ce.id}`, { collecting_event: ce })

const UpdateDepiction = (id, depiction) => ajaxCall('patch', `/depictions/${id}.json`, depiction)

const UpdateGeoreference = (data) => ajaxCall('patch', `/georeferences/${data.id}.json`, { georeference: data })

const UpdateIdentifier = (identifier) => ajaxCall('patch', `/identifiers/${identifier.id}.json`, { identifier: identifier })

const UpdateLabel = (data) => ajaxCall('patch', `/labels/${data.id}.json`, { label: data })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

export {
  GetProjectPreferences,
  GetRecentCollectingEvents,
  GetSoftValidation,
  GetTripCodeByCE,
  GetUserPreferences,
  LoadSoftValidation,
  NavigateCollectingEvents,
  ParseVerbatim,
  RemoveIdentifier,
  UpdateCollectingEvent,
  UpdateDepiction,
  UpdateGeoreference,
  UpdateIdentifier,
  UpdateLabel,
  UpdateUserPreferences
}
