import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init () {
  var store = newStore()
  
  new Vue({
    store,
    el: '#vue-task-slide-breakdown',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-slide-breakdown')) {
    init()
  }
})