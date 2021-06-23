import { createApp } from 'vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import hotkey from 'plugins/v-hotkey'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.directive('hotkey', hotkey)
  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  app.mount('#vue_new_combination')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue_new_combination')) {
    init()
  }
})
