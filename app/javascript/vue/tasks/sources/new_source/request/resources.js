import ajaxCall from 'helpers/ajaxCall'

const GetSource = (id) => {
  return ajaxCall('get', `/sources/${id}`)
}

const CreateSource = (source) => {
  return ajaxCall('post', `/sources`, { source: source })
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

const GetSerialsSmart = function () {
  return ajaxCall('get', `/serials/select_options`)
}

const GetLanguagesSmart = function () {
  return ajaxCall('get', `/languages/select_options?klass=source`)
}

export {
  GetSource,
  CreateSource,
  UpdateSource,
  UpdateUserPreferences,
  GetUserPreferences,
  GetSerialsSmart,
  GetLanguagesSmart
}