import AjaxCall from 'helpers/ajaxCall'

const CreateCitation = data => AjaxCall('post', '/citations.json', data)

const CreateContent = data => AjaxCall('post', '/contents.json', data)

const CreatePinboardItem = data => AjaxCall('post', '/pinboard_items.json', data)

const DeleteCitation = id => AjaxCall('delete', `/citations/${id}.json`)

const DeleteDepiction = id => AjaxCall('delete', `/depictions/${id}.json`)

const GetContent = id => AjaxCall('get', `/contents/${id}.json`)

const GetContents = (data) => AjaxCall('get', '/contents.json', { params: data })

const GetContentCitations = id => AjaxCall('get', `/contents/${id}/citations.json`)

const GetContentDepictions = id => AjaxCall('get', `/contents/${id}/depictions.json`)

const GetOtu = id => AjaxCall('get', `/otus/${id}.json`)

const GetTopics = () => AjaxCall('get', '/topics/list')

const UpdateContent = (id, data) => AjaxCall('patch', `/contents/${id}.json`, data)

const UpdateDepiction = (id, data) => AjaxCall('patch', `/depictions/${id}.json`, data)

const SortDepictions = data => AjaxCall('patch', '/depictions/sort', data)

export {
  CreateCitation,
  CreateContent,
  CreatePinboardItem,
  DeleteCitation,
  DeleteDepiction,
  GetContent,
  GetContents,
  GetContentCitations,
  GetContentDepictions,
  GetOtu,
  GetTopics,
  UpdateContent,
  UpdateDepiction,
  SortDepictions
}
