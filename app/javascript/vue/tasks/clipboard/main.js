import Vue from 'vue'
import App from './app.vue'

function init() {
  Vue.use(require('vue-shortkey'))

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