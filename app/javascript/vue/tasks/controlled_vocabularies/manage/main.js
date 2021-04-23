import Vue from 'vue'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'

function init () {
  Vue.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  new Vue({
    el: '#vue-task-manage-controlled-vocabulary',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-manage-controlled-vocabulary')) {
    init()
  }
})