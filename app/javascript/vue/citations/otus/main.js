import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
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

$(document).on('turbolinks:load', function () {
  if ($('#cite_otus').length) {
    init()
  }
})
