import ajaxCall from 'helpers/ajaxCall'

const batchRemoveKeyword = function (id, type) {
  return ajaxCall('post', `/tags/batch_remove?keyword_id=${id}&klass=${type}`)
}

const createBatchLoad = function (params) {
  return ajaxCall('post', '/loan_items/batch_create', params)
}

const getTagMetadata = function (id) {
  return ajaxCall('get', '/tasks/loans/edit_loan/loan_item_metadata')
}

export {
  batchRemoveKeyword,
  createBatchLoad,
  getTagMetadata
}
