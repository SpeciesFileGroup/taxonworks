import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store'

function init () {
  const store = newStore()
  const app = new Vue({
    el: '#vue-new-collecting-event',
    store,
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
