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
  all: params => AjaxCall('get', `/${model}.json`, { params: Object.assign({}, BASE_PARAMS, params) }),

  create: (data, config) => AjaxCall('post', `/${model}.json`, filterParams(data, permitParams), config),

  destroy: id => AjaxCall('delete', `/${model}/${id}.json`),

  find: (id, params, config) => AjaxCall('get', `/${model}/${id}.json`, { params }, config),

  update: (id, data, config) => AjaxCall('patch', `/${model}/${id}.json`, filterParams(data, Object.assign({}, BASE_PARAMS, permitParams)), config),

  where: (params, config) => AjaxCall('get', `/${model}.json`, { params }, config),

  autocomplete: (params, config) => AjaxCall('get', `/${model}/autocomplete`, { params }, config)
})

export {
  filterParams
}

export const annotations = (model) => ({
  attributions: (id) => AjaxCall('get', `/${model}/${id}/attributions.json`),

  citations: (id) => AjaxCall('get', `/${model}/${id}/citations.json`),

  dataAttributes: (id) => AjaxCall('get', `/${model}/${id}/data_attributes.json`),

  depictions: (id) => AjaxCall('get', `/${model}/${id}/depictions.json`),

  documentation: (id) => AjaxCall('get', `/${model}/${id}/documentation.json`),

  identifiers: (id) => AjaxCall('get', `/${model}/${id}/identifiers.json`),

  notes: (id) => AjaxCall('get', `/${model}/${id}/notes.json`),

  tags: (id) => AjaxCall('get', `/${model}/${id}/tags.json`),

  protocolRelationships: (id) => AjaxCall('get', `/${model}/${id}/protocol_relationships.json`)
})
