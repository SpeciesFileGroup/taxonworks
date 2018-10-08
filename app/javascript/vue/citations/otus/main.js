var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.citations = TW.views.tasks.citations || {}
TW.views.tasks.citations.otus = TW.views.tasks.citations.otus || {}

import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'
import { newStore } from './store/store.js'

Object.assign(TW.views.tasks.citations.otus, {

  init: function () {
    Vue.use(vueResource)
    var token = $('[name="csrf-token"]').attr('content')
    Vue.http.headers.common['X-CSRF-Token'] = token

    new Vue({
      store: newStore,
      el: '#cite_otus',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#cite_otus').length) {
    TW.views.tasks.citations.otus.init()
  }
})
