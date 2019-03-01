var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}
TW.views.task.source = TW.views.task.source || {}
TW.views.task.source.hub = TW.views.task.source.hub || {}


import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.views.task.source.hub, {
  init: function () {
    new Vue({
      el: '#vue-task-source-hub',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-source-hub').length) {
    TW.views.task.source.hub.init()
  }
})
