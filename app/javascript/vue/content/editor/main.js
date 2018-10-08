var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.content = TW.views.tasks.content || {}
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {}

import Vue from 'vue'
import vueResource from 'vue-resource'
import { newStore } from './store/store.js'
import App from './app.vue'

Object.assign(TW.views.tasks.content.editor, {
  init: function () {
    Vue.use(vueResource)
    var token = $('[name="csrf-token"]').attr('content')
    Vue.http.headers.common['X-CSRF-Token'] = token

    new Vue({
      store: newStore,
      el: '#content_editor',
			render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#content_editor').length) {
    TW.views.tasks.content.editor.init()
  }
})
