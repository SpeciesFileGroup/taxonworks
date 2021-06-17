import { createApp } from 'vue'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'
import HelpSystem from 'plugins/help/help'
import en from './lang/en.js'

import { newStore } from './store/store'

function init () {
  const app = createApp(App)
  app.directive('hotkey', hotkey)
  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  app.use(newStore())
  app.mount('#vue-task-otu-browse')
}

$(document).on('turbolinks:load', () => {
  if (document.querySelector('#vue-task-otu-browse')) {
    init()
  }
})
