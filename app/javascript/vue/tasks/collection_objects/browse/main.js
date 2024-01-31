import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './App.vue'

function initApp(element) {
  const app = createApp(App)

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
