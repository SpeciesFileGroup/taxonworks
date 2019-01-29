var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.digitize = TW.views.tasks.digitize || {}

import Vue from 'vue'
import vueResource from 'vue-resource'
import L from 'leaflet'
import vueShortkey from 'vue-shortkey'

Object.assign(TW.views.tasks.digitize, {
  init: function () {
    Vue.use(vueResource)
    Vue.use(vueShortkey)
    var App = require('./app.vue').default
    var store = require('./store/store.js').newStore()
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    new Vue({
      store,
      el: '#vue-all-in-one',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-all-in-one').length) {
    TW.views.tasks.digitize.init()
  }
})
