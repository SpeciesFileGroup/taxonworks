import AjaxCall from 'helpers/ajaxCall'

const CreateExtract = (data) => AjaxCall('post', '/extracts.json', { extract: data })

const GetIdentifierTypes = () => AjaxCall('get', '/identifiers/identifier_types')

const GetRepository = (id) => AjaxCall('get', `/repositories/${id}.json`)

const GetProjectPreferences = () => AjaxCall('get', '/project_preferences.json')

const GetUserPreferences = () => AjaxCall('get', '/preferences.json')

const UpdateExtract = (data) => AjaxCall('patch', `/extracts/${data.id}.json`, { extract: data })

const CreateOriginRelationship = (data) => AjaxCall('post', '/origin_relationships.json', { origin_relationship: data })

const UpdateOriginRelationship = (data) => AjaxCall('post', `/origin_relationships/${data.id}.json`, { origin_relationship: data })

export {
  CreateExtract,
  CreateOriginRelationship,
  GetIdentifierTypes,
  GetRepository,
  GetProjectPreferences,
  GetUserPreferences,
  UpdateExtract,
  UpdateOriginRelationship
}
