import AjaxCall from 'helpers/ajaxCall'

const GetRepository = (id) => AjaxCall('get', `/repositories/${id}.json`)

export {
  GetRepository
}
