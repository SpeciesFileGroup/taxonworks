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

export {
  GetSource,
  CreateSource,
  UpdateSource
}