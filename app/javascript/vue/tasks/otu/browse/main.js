import Vue from 'vue'
import App from './app.vue'
import vueShortkey from 'vue-shortkey'

import { newStore } from './store/store'

function init () {
  Vue.use(vueShortkey)

  new Vue({
    el: '#vue-task-otu-browse',
    store: newStore(),
    render: function (createElement) {
      return createElement(App)
    }
  })
}

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-otu-browse').length) {
    init()
  }
})
