import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

let app

function initApp(element) {
  app = createApp(App)
  app.use(createPinia())
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-browse-sound')

  if (el) {
    initApp(el)
  }
})

document.addEventListener('turbolinks:before-render', () => {
  if (app) app.unmount()
})
