import Vue from 'vue'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import { newStore } from './store/store'

function init () {
  Vue.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  new Vue({
    el: '#vue-task-dwca-import-new',
    store: newStore(),
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-dwca-import-new')) {
    init()
  }
})
