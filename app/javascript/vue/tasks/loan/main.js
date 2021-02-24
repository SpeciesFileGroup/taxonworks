import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  var store = newStore()

  new Vue({
    store,
    el: '#edit_loan_task',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#edit_loan_task')) {
    init()
  }
})
