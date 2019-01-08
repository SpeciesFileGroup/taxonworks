var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}
TW.views.task.labels = TW.views.task.labels || {}
TW.views.task.labels.print_labels = TW.views.task.labels.print_labels || {}

import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.views.task.labels.print_labels, {
  init: function () {
    new Vue({
      el: '#vue-task-labels-print-labels',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-labels-print-labels').length) {
    TW.views.task.labels.print_labels.init()
  }
})
