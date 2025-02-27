import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './App.vue'
import HelpSystem from '@/plugins/help/help'
import en from './help/en'

function initApp(element) {
  const app = createApp(App)
 
  app.use(HelpSystem, {
    languages: {
      en
    }
  })

  app.use(newStore())
  app.mount(element)

  document.addEventListener(
    'turbolinks:before-render',
    () => {
      if (app) {
        app.unmount()
      }
    },
    { once: true }
  )
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-browse-collection-object')

  if (el) {
    initApp(el)
  }
})
