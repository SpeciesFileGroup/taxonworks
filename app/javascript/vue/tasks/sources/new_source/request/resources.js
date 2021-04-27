import ajaxCall from 'helpers/ajaxCall'

const CreateDocumentation = (documentation) => ajaxCall('post', '/documentation.json', { documentation: documentation })

const GetRecentSources = () => ajaxCall('get', '/sources.json', { params: { per: 10, recent: true } })

const GetSerialMatch = (title) => ajaxCall('get', '/serials.json', { params: { name: title } })

const GetSourceDocumentations = (id) => ajaxCall('get', `/sources/${id}/documentation`)

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const RemoveDocumentation = (id) => ajaxCall('delete', `/documentation/${id}.json`)

const UpdateDocument = (data) => ajaxCall('patch', `/documents/${data.id}.json`, { document: data })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

export {
  CreateDocumentation,
  GetRecentSources,
  GetSerialMatch,
  GetSourceDocumentations,
  GetUserPreferences,
  RemoveDocumentation,
  UpdateDocument,
  UpdateUserPreferences
}
