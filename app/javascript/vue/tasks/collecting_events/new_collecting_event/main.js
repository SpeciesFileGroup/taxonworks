import Vue from 'vue'
import App from './app.vue'

function init () {
  const app = new Vue({
    el: '#vue-new-collecting-event',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-new-collecting-event')) {
    init()
  }
})