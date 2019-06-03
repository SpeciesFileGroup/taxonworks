import Vue from 'vue'
import vueResource from 'vue-resource'
import App from './app.vue'

function init() {
    Vue.use(vueResource)
    Vue.use(require('vue-shortkey'))

    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    new Vue({
      el: '#vue-clipboard-app',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-clipboard-app')) {
    init()
  }
})