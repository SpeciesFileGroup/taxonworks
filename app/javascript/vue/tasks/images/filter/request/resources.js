import ajaxCall from 'helpers/ajaxCall'

const GetDepictions = (params) => {
  return ajaxCall('get', '/depictions.json', { params: params })
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

export {
  GetDepictions,
  GetUsers
}
