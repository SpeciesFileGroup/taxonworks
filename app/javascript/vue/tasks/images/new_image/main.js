import Vue from 'vue'
import App from './app.vue'
import vueResource from 'vue-resource'
import vueShortkey from 'vue-shortkey'

function init() {
    Vue.use(vueResource)
    Vue.use(vueShortkey)
    var store = require('./store/store.js').newStore()

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
