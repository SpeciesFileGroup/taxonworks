import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store'

function init () {
  new Vue({
    store: newStore(),
    el: '#vue-interactive-keys',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-interactive-keys')) {
    init()
  }
})