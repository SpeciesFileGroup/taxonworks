import { createApp } from 'vue'
import { newStore } from './store/store.js'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function init() {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })

  app.directive('hotkey', hotkey)
  app.use(newStore())
  app.mount('#new_taxon_name_task')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#new_taxon_name_task')) {
    init()
  }
})
