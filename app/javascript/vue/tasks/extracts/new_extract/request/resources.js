import AjaxCall from 'helpers/ajaxCall'

const CreateExtract = data => AjaxCall('post', '/extracts.json', { extract: data })

const DestroyExtract = id => AjaxCall('delete', `/extracts/${id}.json`)

const GetExtract = id => AjaxCall('get', `/extracts/${id}.json`)

const GetExtracts = data => AjaxCall('get', '/extracts.json', { params: data })

const GetSoftValidation = globalId => AjaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const GetIdentifierTypes = () => AjaxCall('get', '/identifiers/identifier_types')

const GetRepository = id => AjaxCall('get', `/repositories/${id}.json`)

const GetOriginRelationships = params => AjaxCall('get', '/origin_relationships.json', { params: params })

const GetProjectPreferences = () => AjaxCall('get', '/project_preferences.json')

const GetUserPreferences = () => AjaxCall('get', '/preferences.json')

const UpdateExtract = data => AjaxCall('patch', `/extracts/${data.id}.json`, { extract: data })

const CreateOriginRelationship = data => AjaxCall('post', '/origin_relationships.json', { origin_relationship: data })

const UpdateOriginRelationship = data => AjaxCall('post', `/origin_relationships/${data.id}.json`, { origin_relationship: data })

export {
  CreateExtract,
  CreateOriginRelationship,
  DestroyExtract,
  GetExtract,
  GetExtracts,
  GetOriginRelationships,
  GetIdentifierTypes,
  GetRepository,
  GetSoftValidation,
  GetProjectPreferences,
  GetUserPreferences,
  UpdateExtract,
  UpdateOriginRelationship
}
