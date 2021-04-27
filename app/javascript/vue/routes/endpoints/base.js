import AjaxCall from 'helpers/ajaxCall'
import { isObject } from 'helpers/objects'

const filterParams = (params, allowParams) => {
  const newObj = {}
  const properties = Array.isArray(params) ? params : Object.keys(params)
  const allowProperties = Object.keys(allowParams)

  if (!Object.keys(allowProperties).length) {
    return params
  }

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
  all: () => AjaxCall('get', `/${model}.json`),

  create: (data) => AjaxCall('post', `/${model}.json`, filterParams(data, permitParams)),

  destroy: (id) => AjaxCall('delete', `/${model}/${id}.json`),

  find: (id) => AjaxCall('get', `/${model}/${id}.json`),

  update: (id, data) => AjaxCall('patch', `/${model}/${id}.json`, filterParams(data, permitParams)),

  where: (params) => AjaxCall('get', `/${model}.json`, { params: params })
})

export {
  filterParams
}

export const annotations = (model) => ({
  citations: (id) => AjaxCall('get', `/${model}/${id}/citations.json`)
})
