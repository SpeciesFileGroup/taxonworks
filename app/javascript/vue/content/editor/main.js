import Vue from 'vue'
import vueResource from 'vue-resource'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
  Vue.use(vueResource)
  var token = document.querySelector('meta[name="csrf-token"]')
  if(token) {
    Vue.http.headers.common['X-CSRF-Token'] = token.getAttribute('content')
  }

  new Vue({
    store: newStore,
    el: '#content_editor',
		render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#content_editor')) {
    init()
  }
})
