import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import HelpSystem from '@/plugins/help/help'
import en from './lang/en.js'

function init() {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })

  app.use(createPinia())
  app.mount('#vue-task-otu-browse')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-otu-browse')) {
    init()
  }
})
