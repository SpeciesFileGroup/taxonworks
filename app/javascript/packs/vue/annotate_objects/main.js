var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.annotate_object = TW.views.tasks.annotate_object || {}

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.annotate_object, {

  init: function () {
    Vue.use(vueResource)

    //var store = require('./store/store.js').newStore()
    var App = require('./app.vue').default
    var token = $('[name="csrf-token"]').attr('content')
    Vue.http.headers.common['X-CSRF-Token'] = token

    new Vue({
      //store,
      el: '#annotate_object',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#annotate_object').length) {
    TW.views.tasks.annotate_object.init()
  }
})