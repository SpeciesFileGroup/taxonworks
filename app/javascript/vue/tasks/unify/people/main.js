import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'
import HelpSystem from '@/plugins/help/help.js'
import en from './lang/en.js'

function init() {
  const app = createApp(App)
  app.use(HelpSystem, {
    languages: {
      en
    }
  })
  app.use(newStore())
  app.mount('#unify_people')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#unify_people')) {
    init()
  }
})
