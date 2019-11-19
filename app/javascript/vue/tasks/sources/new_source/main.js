import Vue from 'vue'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'

import { newStore } from './store/store.js'

import en from './lang/help/en'

function init () {
  Vue.use(HelpSystem, { 
    languages: {
      en: en
    }
  })
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