var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.new_combination = TW.views.tasks.new_combination || {}

import Vue from 'vue'
import vueResource from 'vue-resource'
import HelpSystem from '../plugins/help/help'
import en from './lang/help/en'

Object.assign(TW.views.tasks.new_combination, {
  init: function () {
    Vue.use(vueResource)
    Vue.use(require('vue-shortkey'))
    Vue.use(HelpSystem, { 
      languages: {
        en: en
      }
    })

    var App = require('./app.vue').default
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    new Vue({
      el: '#vue_new_combination',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue_new_combination').length) {
    TW.views.tasks.new_combination.init()
  }
})
