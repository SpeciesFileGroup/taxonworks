import { createApp } from 'vue'
import App from './app.vue'
import HelpSystem from '@/plugins/help/help'
import en from './lang/en'

function init() {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en
    }
  })
  app.mount('#author_by_letter')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#author_by_letter')) {
    init()
  }
})
