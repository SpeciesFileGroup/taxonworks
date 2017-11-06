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

const getLoan = function(id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/loans/${id}.json`).then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const updateLoan = function(loan) {
  return new Promise(function (resolve, reject) {
    Vue.http.patch(`/loans/${loan.id}.json`, { loan: loan }).then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const createLoan = function(loan) {
  return new Promise(function (resolve, reject) {
    Vue.http.post(`/loans.json`, loan).then( response => {
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
  getTagMetadata,
  getLoan,
  getLoanItems,
  createLoan,
  updateLoan
}