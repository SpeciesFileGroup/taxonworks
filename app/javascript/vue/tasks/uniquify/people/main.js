import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

function init() {
  Vue.use(vueResource);

  var token = $('[name="csrf-token"]').attr('content')
  Vue.http.headers.common['X-CSRF-Token'] = token

  new Vue({
    el: '#uniquify_people',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

$(document).on('turbolinks:load', function () {
  if (document.querySelector('#uniquify_people')) {
    init()
  }
});