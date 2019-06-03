import Vue from 'vue'
import vueResource from 'vue-resource'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
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

$(document).on('turbolinks:load', function () {
  if (document.querySelector('#content_editor')) {
    init()
  }
})
