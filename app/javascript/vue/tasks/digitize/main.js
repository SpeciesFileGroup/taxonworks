import Vue from 'vue'
import vueResource from 'vue-resource'
import L from 'leaflet'
import vueShortkey from 'vue-shortkey'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  Vue.use(vueResource)
  Vue.use(vueShortkey)
  var store = newStore()
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  new Vue({
    store,
    el: '#vue-all-in-one',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-all-in-one')) {
    init()
  }
})
