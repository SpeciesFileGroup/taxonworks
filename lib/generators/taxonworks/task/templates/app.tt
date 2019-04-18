var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}


import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.views.task, {
  init: function () {
    new Vue({
      el: '#vue-task',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task').length) {
    TW.views.task.init()
  }
})
