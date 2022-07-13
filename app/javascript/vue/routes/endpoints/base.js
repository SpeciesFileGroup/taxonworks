import AjaxCall from 'helpers/ajaxCall'
import { isObject } from 'helpers/objects'

const BASE_PARAMS = {
  extend: Array,
  embed: Array
}

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
  all: params => AjaxCall('get', `/${model}.json`, { params }),

  create: (data, config) => AjaxCall('post', `/${model}.json`, filterParams(data, { ...BASE_PARAMS, ...permitParams }), config),

  destroy: id => AjaxCall('delete', `/${model}/${id}.json`),

  find: (id, params, config) => AjaxCall('get', `/${model}/${id}.json`, { params }, config),

  update: (id, data, config) => AjaxCall('patch', `/${model}/${id}.json`, filterParams(data, { ...BASE_PARAMS, ...permitParams }), config),

  where: (params, config) => AjaxCall('get', `/${model}.json`, { params }, config),

  autocomplete: (params, config) => AjaxCall('get', `/${model}/autocomplete`, { params }, config)
})

export {
  filterParams
}

export const annotations = model => ({
  attributions: (id, params) => AjaxCall('get', `/${model}/${id}/attributions.json`, { params }),

  citations: (id, params) => AjaxCall('get', `/${model}/${id}/citations.json`, { params }),

  dataAttributes: (id, params) => AjaxCall('get', `/${model}/${id}/data_attributes.json`, { params }),

  depictions: (id, params) => AjaxCall('get', `/${model}/${id}/depictions.json`, { params }),

  documentation: (id, params) => AjaxCall('get', `/${model}/${id}/documentation.json`, { params }),

  identifiers: (id, params) => AjaxCall('get', `/${model}/${id}/identifiers.json`, { params }),

  notes: (id, params) => AjaxCall('get', `/${model}/${id}/notes.json`, { params }),

  tags: (id, params) => AjaxCall('get', `/${model}/${id}/tags.json`, { params }),

  protocolRelationships: (id, params) => AjaxCall('get', `/${model}/${id}/protocol_relationships.json`, { params })
})
