import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

function init() {
  Vue.use(vueResource)
  var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  Vue.http.headers.common['X-CSRF-Token'] = token

  new Vue({
    el: '#single_bibtex_source',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#single_bibtex_source')) {
    init()
  }
});