import { createApp } from 'vue'
import App from './app.vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en.js'

function init () {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })

  app.mount('#new_namespace_task')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#new_namespace_task')) {
    init()
  }
})
