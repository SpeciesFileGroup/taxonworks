var TW = TW || {}
TW.views = TW.views || {}
TW.views.task = TW.views.task || {}
TW.views.task.images = TW.views.task.images || {}
TW.views.task.images.new = TW.views.task.images.new || {}


import Vue from 'vue'
import App from './app.vue'
import vueResource from 'vue-resource'
import vueShortkey from 'vue-shortkey'

Object.assign(TW.views.task.images.new, {
  init: function () {
    Vue.use(vueResource)
    Vue.use(vueShortkey)
    var store = require('./store/store.js').newStore()

    new Vue({
      store,
      el: '#vue-task-images-new',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#vue-task-images-new').length) {
    TW.views.task.images.new.init()
  }
})
