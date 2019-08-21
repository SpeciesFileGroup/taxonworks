import Vue from 'vue'
import App from './app.vue'

function init () {
  new Vue({
    el: '#vue-sqed-buffered',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-sqed-buffered')) {
    init()
  }
})
