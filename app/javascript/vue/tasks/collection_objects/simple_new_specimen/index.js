import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

function initApp (element) {
  const app = createApp(App)
  const pinia = createPinia()

  app.use(pinia)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-simple-new-specimen')

  if (el) { initApp(el) }
})
