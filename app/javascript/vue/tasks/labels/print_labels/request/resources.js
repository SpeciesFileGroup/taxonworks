import ajaxCall from 'helpers/ajaxCall'

const GetLabel = (id) => ajaxCall('get', `/labels/${id}.json`)

const GetLabels = function () {
  return ajaxCall('get', '/labels.json')
}

const UpdateLabel = function (label) {
  return ajaxCall('patch', `/labels/${label.id}.json`, { label: label })
}

const CreateLabel = function (label) {
  return ajaxCall('post', '/labels.json', { label: label })
}

const RemoveLabel = function (id) {
  return ajaxCall('delete', `/labels/${id}.json`)
}

export {
  GetLabel,
  GetLabels,
  CreateLabel,
  UpdateLabel,
  RemoveLabel
}
