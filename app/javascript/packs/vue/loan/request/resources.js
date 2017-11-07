import Vue from 'vue'; 
import VueResource from 'vue-resource';

Vue.use(VueResource);
Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

const getTagMetadata = function() {
  return new Promise(function (resolve, reject) {
    Vue.http.get('/tasks/loans/edit_loan/loan_item_metadata').then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const createBatchLoad = function(params) {
  return new Promise(function(resolve,reject) {
    Vue.http.post('/loan_items/batch_create', params).then(response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    })
  });
}

const getLoan = function(id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/loans/${id}.json`).then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const destroyLoanItem = function(id) {
  return new Promise(function (resolve, reject) {
    Vue.http.delete(`/loan_items/${id}.json`).then( response => {
      TW.workbench.alert.create("Loan item was successfully deleted.", "notice");
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const updateLoan = function(loan) {
  return new Promise(function (resolve, reject) {
    Vue.http.patch(`/loans/${loan.id}.json`, { loan: loan }).then( response => {
      TW.workbench.alert.create("Loan item was successfully updated.", "notice");
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const createLoan = function(loan) {
  return new Promise(function (resolve, reject) {
    console.log(loan);
    Vue.http.post(`/loans.json`, { loan: loan }).then( response => {
      TW.workbench.alert.create("Loan was successfully created.", "notice");
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const createLoanItem = function(loan_item) {
  return new Promise(function (resolve, reject) {
    Vue.http.post(`/loan_items.json`, { loan_item: loan_item }).then( response => {
      TW.workbench.alert.create("Loan item was successfully created.", "notice");
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const getLoanItems = function(id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/loan_items.json?loan_id=${id}`).then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

export {
  createBatchLoad,
  destroyLoanItem,
  getTagMetadata,
  getLoan,
  getLoanItems,
  createLoanItem,
  createLoan,
  updateLoan
}