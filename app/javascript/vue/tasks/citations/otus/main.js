import Vue from 'vue'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  new Vue({
    store: newStore,
    el: '#cite_otus',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#cite_otus')) {
    init()
  }
})
