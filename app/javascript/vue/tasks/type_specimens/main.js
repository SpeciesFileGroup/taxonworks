import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'
import { newStore } from './store/store.js'
import vueShortkey from 'vue-shortkey'

function init() {
  var store = newStore()

  Vue.use(vueResource)
  Vue.use(vueShortkey)
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  new Vue({
    store,
		el: '#vue_type_specimens',
		render: function (createElement) {
      return createElement(App)
		}
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue_type_specimens')) {
    init()
  }
})
