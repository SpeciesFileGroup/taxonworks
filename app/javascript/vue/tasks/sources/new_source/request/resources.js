import ajaxCall from 'helpers/ajaxCall'

const CloneSource = (id) => ajaxCall('post', `/sources/${id}/clone`)

const CreateDocumentation = (documentation) => ajaxCall('post', '/documentation.json', { documentation: documentation })

const CreateSource = (source) => ajaxCall('post', '/sources', { source: source })

const GetRecentSources = () => ajaxCall('get', '/sources.json', { params: { per: 10, recent: true } })

const GetSerialMatch = (title) => ajaxCall('get', '/serials.json', { params: { name: title } })

const GetSource = (id) => ajaxCall('get', `/sources/${id}.json`)

const GetSourceDocumentations = (id) => ajaxCall('get', `/sources/${id}/documentation`)

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const LoadSoftValidation = (globalId) => ajaxCall('get', `/soft_validations/validate?global_id=${globalId}`)

const RemoveDocumentation = (id) => ajaxCall('delete', `/documentation/${id}.json`)

const UpdateDocument = (data) => ajaxCall('patch', `/documents/${data.id}.json`, { document: data })

const UpdateSource = (source) => ajaxCall('patch', `/sources/${source.id}`, { source: source })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

export {
  CloneSource,
  CreateDocumentation,
  CreateSource,
  GetRecentSources,
  GetSerialMatch,
  GetSource,
  GetSourceDocumentations,
  GetUserPreferences,
  LoadSoftValidation,
  RemoveDocumentation,
  UpdateDocument,
  UpdateSource,
  UpdateUserPreferences
}
