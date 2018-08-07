var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.digitize = TW.views.tasks.digitize || {}

import Vue from 'vue'
import vueResource from 'vue-resource'
import L from 'leaflet'
delete L.Icon.Default.prototype._getIconUrl

L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png')
});

Object.assign(TW.views.tasks.digitize, {
  init: function () {
    Vue.use(vueResource)
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
