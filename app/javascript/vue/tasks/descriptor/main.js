import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

function init () {
  Vue.use(vueResource)
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  new Vue({
    el: '#descriptor_task',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

$(document).on('turbolinks:load', function () {
  if (document.querySelector('#descriptor_task')) {
    init()
  }
})