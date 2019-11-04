import Vue from 'vue'
import App from './app.vue'

import { newStore } from './store/store.js'

function init (){
  var store = newStore()
  new Vue({
    el: '#vue-task-new-source',
    store,
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-new-source')) {
    init()
  }
})