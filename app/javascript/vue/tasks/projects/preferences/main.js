var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}
TW.views.task.projects = TW.views.task.projects || {}
TW.views.task.projects.preferences = TW.views.task.projects.preferences || {}

import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.views.task.projects.preferences, {
  init: function () {
    new Vue({
      el: '#vue-task-preferences',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-preferences').length) {
    TW.views.task.projects.preferences.init()
  }
})
