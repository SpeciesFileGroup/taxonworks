import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init () {
  const app = new Vue({
    store: newStore(),
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