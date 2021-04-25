import AjaxCall from 'helpers/ajaxCall'
import { isObject } from 'helpers/objects'

const filterParams = (params, allowParams) => {
  console.log(params)
  const newObj = {}
  const properties = Array.isArray(params) ? params : Object.keys(params)
  const allowProperties = Object.keys(allowParams)

  properties.forEach(property => {
    if (allowProperties.includes(property)) {
      const paramValue = params[property]

      if (Array.isArray(paramValue)) {
        newObj[property] = paramValue.map(item => filterParams(item, allowParams[property]))
      } else if (isObject(paramValue)) {
        newObj[property] = filterParams(paramValue, allowParams[property])
      } else {
        newObj[property] = paramValue
      }
    }
  })

  return newObj
}

export default (model, permitParams) => ({
  create: (data) => AjaxCall('post', `/${model}.json`, filterParams(data, permitParams)),

  destroy: (id) => AjaxCall('delete', `/${model}/${id}.json`),

  find: (id) => AjaxCall('get', `/${model}/${id}.json`),

  index: (params) => AjaxCall('get', `/${model}.json`, { params: params }),

  update: (id, data) => AjaxCall('patch', `/${model}/${id}.json`, filterParams(data, permitParams))
})
