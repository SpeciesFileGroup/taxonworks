import Vue from 'vue'
import App from './app.vue'
import vueShortkey from 'vue-shortkey'
import HelpSystem from 'plugins/help/help'
import en from './lang/en.js'

import { newStore } from './store/store'

function init () {
  Vue.use(HelpSystem, {
    languages: {
      en: en
    }
  })
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
