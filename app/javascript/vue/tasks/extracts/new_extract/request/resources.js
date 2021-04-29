import AjaxCall from 'helpers/ajaxCall'

const CreateExtract = data => AjaxCall('post', '/extracts.json', { extract: data })

const CreateIdentifier = data => AjaxCall('post', '/identifiers.json', { identifier: data })

const CreateProtocol = data => AjaxCall('post', '/protocol_relationships.json', { protocol_relationship: data })

const DestroyExtract = id => AjaxCall('delete', `/extracts/${id}.json`)

const DestroyIdentifier = id => AjaxCall('delete', `/identifiers/${id}.json`)

const DestroyProtocol = id => AjaxCall('delete', `/protocol_relationships/${id}.json`)

const GetExtract = id => AjaxCall('get', `/extracts/${id}.json`)

const GetExtracts = data => AjaxCall('get', '/extracts.json', { params: data })

const GetSoftValidation = globalId => AjaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const GetIdentifiers = id => AjaxCall('get', `/extracts/${id}/identifiers.json`)

const GetIdentifierTypes = () => AjaxCall('get', '/identifiers/identifier_types')

const GetRepository = id => AjaxCall('get', `/repositories/${id}.json`)

const GetOriginRelationships = params => AjaxCall('get', '/origin_relationships.json', { params: params })

const GetProjectPreferences = () => AjaxCall('get', '/project_preferences.json')

const GetProtocols = (id) => AjaxCall('get', `/extracts/${id}/protocol_relationships.json`)

const GetUserPreferences = () => AjaxCall('get', '/preferences.json')

const UpdateExtract = data => AjaxCall('patch', `/extracts/${data.id}.json`, { extract: data })

const UpdateProtocol = data => AjaxCall('patch', `/protocol_relationships/${data.id}.json`, { protocol_relationships: data})

const CreateOriginRelationship = data => AjaxCall('post', '/origin_relationships.json', { origin_relationship: data })

const UpdateOriginRelationship = data => AjaxCall('patch', `/origin_relationships/${data.id}.json`, { origin_relationship: data })

export {
  CreateExtract,
  CreateIdentifier,
  CreateOriginRelationship,
  CreateProtocol,
  DestroyExtract,
  DestroyProtocol,
  DestroyIdentifier,
  GetExtract,
  GetExtracts,
  GetIdentifiers,
  GetProtocols,
  GetOriginRelationships,
  GetIdentifierTypes,
  GetRepository,
  GetSoftValidation,
  GetProjectPreferences,
  GetUserPreferences,
  UpdateExtract,
  UpdateOriginRelationship,
  UpdateProtocol
}
