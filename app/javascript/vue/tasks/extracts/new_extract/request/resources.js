import AjaxCall from 'helpers/ajaxCall'

const CreateExtract = (data) => AjaxCall('post', '/extracts.json', { extract: data })

const GetIdentifierTypes = () => AjaxCall('get', '/identifiers/identifier_types')

const GetRepository = (id) => AjaxCall('get', `/repositories/${id}.json`)

const GetProjectPreferences = () => AjaxCall('get', '/project_preferences.json')

const GetUserPreferences = () => AjaxCall('get', '/preferences.json')

const UpdateExtract = (data) => AjaxCall('patch', `/extract/${data.id}.json`, { extract: data })

export {
  CreateExtract,
  GetIdentifierTypes,
  GetRepository,
  GetProjectPreferences,
  GetUserPreferences,
  UpdateExtract
}
