import ajaxCall from 'helpers/ajaxCall'

const create = function (url, data) {
  return ajaxCall('post', url, data)
}

const update = function (url, data) {
  return ajaxCall('patch', url, data)
}

const destroy = function (url, data) {
  return ajaxCall('delete', url, data)
}

const getList = function (url, data = {}) {
  return ajaxCall('get', url, data)
}

const vueCrud = {
  methods: {
    create: create,
    update: update,
    destroy: destroy,
    getList: getList
  }
}

export default vueCrud
