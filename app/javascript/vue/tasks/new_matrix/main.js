import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  var store = newStore()
  new Vue({
    store,
    el: '#vue_new_matrix_task',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue_new_matrix_task')) {
    init()
  }
})
