import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'
import vueShortkey from 'vue-shortkey'

function init() {
  var store = newStore()
  Vue.use(vueShortkey)
  
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
