import { createApp } from 'vue'
import { newStore } from './store/store.js'
import HelpSystem from '@/plugins/help/help'
import en from './lang/help/en'
import App from './app.vue'

function init() {
  const app = createApp(App)
  app.use(newStore())
  app.use(HelpSystem, {
    languages: {
      en: en
    }
  })

  app.mount('#vue-all-in-one')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-all-in-one')) {
    init()
  }
})
