import Vue from 'vue'
import vueShortkey from 'vue-shortkey'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  Vue.use(vueShortkey)
  var store = newStore()

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
