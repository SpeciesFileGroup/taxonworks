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

export {
  GetSource,
  CreateSource,
  UpdateSource,
  UpdateUserPreferences,
  GetUserPreferences
}