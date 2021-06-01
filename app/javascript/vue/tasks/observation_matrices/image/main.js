import Vue from 'vue'
import App from './app.vue'

import { newStore } from './store/store'

function init (){
  var store = newStore()
  new Vue({
    el: '#vue-task-matrix-image',
    store,
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-matrix-image')) {
    init()
  }
})