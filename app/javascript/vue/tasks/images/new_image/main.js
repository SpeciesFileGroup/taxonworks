import Vue from 'vue'
import App from './app.vue'
import vueShortkey from 'vue-shortkey'
import { newStore } from './store/store'

function init() {
  Vue.use(vueShortkey)
  var store = newStore()

  new Vue({
    store,
    el: '#vue-task-images-new',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-task-images-new')) {
    init()
  }
})
