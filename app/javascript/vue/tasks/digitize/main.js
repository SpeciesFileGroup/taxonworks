import Vue from 'vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import vueShortkey from 'vue-shortkey'
import App from './app.vue'
import { newStore } from './store/store.js'

function init() {
  var store = newStore()

  Vue.use(vueShortkey)
  Vue.use(HelpSystem, {
    languages: {
      en: en
    }
  })

  new Vue({
    store,
    el: '#vue-all-in-one',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-all-in-one')) {
    init()
  }
})
