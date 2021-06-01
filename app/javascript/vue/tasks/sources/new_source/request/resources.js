import ajaxCall from 'helpers/ajaxCall'

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

export {
  GetUserPreferences,
  UpdateUserPreferences
}
