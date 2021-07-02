import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'
import hotkey from 'plugins/v-hotkey'
import en from './lang/help/en'

function init () {
  const app = createApp(App)

  app.directive('hotkey', hotkey)
  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  app.use(newStore())
  app.mount('#vue-task-new-source')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-new-source')) {
    init()
  }
})
