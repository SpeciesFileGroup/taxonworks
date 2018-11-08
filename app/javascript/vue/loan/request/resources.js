import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)
const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      return resolve(response.body)
    }, response => {
      handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  let errors = Object.keys(json)
  let errorMessage = ''

  errors.forEach(function (item) {
    errorMessage += json[item].join('<br>')
  })

  TW.workbench.alert.create(errorMessage, 'error')
}

const createTaxonDetermination = function (data) {
  return ajaxCall('post', '/taxon_determinations', data)
}

const batchRemoveKeyword = function (id, type) {
  return ajaxCall('post', `/tags/batch_remove?keyword_id=${id}&klass=${type}`)
}

const createBatchLoad = function (params) {
  return ajaxCall('post', '/loan_items/batch_create', params)
}

const createLoan = function (loan) {
  return ajaxCall('post', `/loans.json`, loan)
}

const createLoanItem = function (loan_item) {
  return ajaxCall('post', `/loan_items.json`, loan_item)
}

const getLoan = function (id) {
  return ajaxCall('get', `/loans/${id}.json`)
}

const getLoanItems = function (id) {
  return ajaxCall('get', `/loan_items.json?loan_id=${id}`)
}

const getTagMetadata = function (id) {
  return ajaxCall('get', `/tasks/loans/edit_loan/loan_item_metadata`)
}

const destroyLoan = function (id) {
  return ajaxCall('delete', `/loans/${id}.json`)
}

const destroyLoanItem = function (id) {
  return ajaxCall('delete', `/loan_items/${id}.json`)
}

const updateLoan = function (loan) {
  return ajaxCall('patch', `/loans/${loan.loan.id}.json`, loan)
}

const updateLoanItem = function (loan_item) {
  return ajaxCall('patch', `/loan_items/${loan_item.loan_item.id}.json`, loan_item)
}

export {
  batchRemoveKeyword,
  createTaxonDetermination,
  createBatchLoad,
  destroyLoan,
  destroyLoanItem,
  getTagMetadata,
  getLoan,
  getLoanItems,
  createLoanItem,
  createLoan,
  updateLoan,
  updateLoanItem
}
