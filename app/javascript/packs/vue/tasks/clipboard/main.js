var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.descriptor = TW.views.tasks.descriptor || {}

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.descriptor, {
  init: function () {
    Vue.use(vueResource)
    Vue.use(require('vue-shortkey'))

    var App = require('./app.vue').default
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    new Vue({
      el: '#vue-clipboard-app',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-clipboard-app').length) {
    TW.views.tasks.descriptor.init()
  }
})