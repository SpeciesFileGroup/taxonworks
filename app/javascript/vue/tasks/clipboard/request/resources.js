import ajaxCall from 'helpers/ajaxCall'

const UpdateClipboard = function (clipboard) {
  return ajaxCall('put', `/project_members/update_clipboard.json`, { project_member: { clipboard: clipboard } })
}

const GetClipboard = function () {
  return ajaxCall('get', `/project_members/clipboard.json`)
}

export {
  GetClipboard,
  UpdateClipboard
}