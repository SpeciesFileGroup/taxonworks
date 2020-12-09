import AjaxCall from 'helpers/ajaxCall'

const GetRoleTypes = () => AjaxCall('get', '/people/role_types.json')

const GetPeople = (id) => AjaxCall('get', `/people/${id}.json`)

const GetPeopleList = (data) => AjaxCall('get', '/people.json', { params: data })

const GetPeopleSimilar = (id) => AjaxCall('get', `/people/${id}/similar.json`)

const PersonMerge = (id, params) => AjaxCall('post', `/people/${id}/merge`, params)

export {
  GetRoleTypes,
  GetPeople,
  GetPeopleList,
  GetPeopleSimilar,
  PersonMerge
}
