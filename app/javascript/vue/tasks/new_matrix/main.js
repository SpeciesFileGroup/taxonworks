import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'
import { newStore } from './store/store.js'

  function init() {
    Vue.use(vueResource)
    var store = newStore()
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

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
