var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}
TW.views.task.asserted_distribution = TW.views.task.asserted_distribution || {}
TW.views.task.asserted_distribution.new = TW.views.task.asserted_distribution.new || {}


import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.views.task.asserted_distribution.new, {
  init: function () {
    new Vue({
      el: '#vue-task-asserted-distribution-new',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-asserted-distribution-new').length) {
    TW.views.task.asserted_distribution.new.init()
  }
})
