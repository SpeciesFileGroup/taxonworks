import Vue from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function init() {
  new Vue({
    store: newStore,
    el: '#content_editor',
		render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#content_editor')) {
    init()
  }
})
