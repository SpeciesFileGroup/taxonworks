import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store'

function init () {
  new Vue({
    el: '#vue-task-observation-dashboard',
    store: newStore(),
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-observation-dashboard')) {
    init()
  }
})
