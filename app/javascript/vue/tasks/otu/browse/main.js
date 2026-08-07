import { createApp } from 'vue'
import { newStore } from './store/store'
import App from './app.vue'
import HelpSystem from '@/plugins/help/help'
import en from './lang/en.js'

function init() {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })
  app.use(newStore())
  app.mount('#vue-task-otu-browse')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-otu-browse')) {
    init()
  }
})
