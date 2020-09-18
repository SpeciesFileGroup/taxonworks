import ajaxCall from 'helpers/ajaxCall'

const GetSerialMatch = (title) => ajaxCall('get', '/serials.json', { params: { name: title } })

const GetSource = (id) => {
  return ajaxCall('get', `/sources/${id}.json`)
}

const GetRecentSources = () => {
  return ajaxCall('get', '/sources.json', {
    params: {
      per: 10,
      recent: true
    }
  })
}

const CreateSource = (source) => {
  return ajaxCall('post', '/sources', { source: source })
}

const UpdateSource = (source) => {
  return ajaxCall('patch', `/sources/${source.id}`, { source: source })
}

const UpdateUserPreferences = function (id, data) {
  return ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })
}

const GetUserPreferences = function () {
  return ajaxCall('get', `/preferences.json`)
}

const CloneSource = function (id) {
  return ajaxCall('post', `/sources/${id}/clone`)
}

const LoadSoftValidation = function (global_id) {
  return ajaxCall('get', `/soft_validations/validate?global_id=${global_id}`)
}

export {
  GetSource,
  GetRecentSources,
  GetSerialMatch,
  CreateSource,
  UpdateSource,
  UpdateUserPreferences,
  GetUserPreferences,
  CloneSource,
  LoadSoftValidation
}