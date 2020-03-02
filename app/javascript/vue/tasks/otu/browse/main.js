var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}
TW.views.task.otu = TW.views.task.otu || {}
TW.views.task.otu.browse = TW.views.task.otu.browse || {}

import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.views.task.otu.browse, {
  init: function () {
    new Vue({
      el: '#vue-task-otu-browse',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-otu-browse').length) {
    TW.views.task.otu.browse.init()
  }
})
