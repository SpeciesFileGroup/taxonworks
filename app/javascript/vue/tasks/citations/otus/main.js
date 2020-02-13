import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  Vue.use(vueResource)
  var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  Vue.http.headers.common['X-CSRF-Token'] = token

  new Vue({
    store: newStore,
    el: '#cite_otus',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#cite_otus')) {
    init()
  }
})
