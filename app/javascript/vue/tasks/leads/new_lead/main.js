import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './app.vue'

function initApp (element) {
  const app = createApp(App)
  const pinia = createPinia()

  app.use(pinia)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#new_lead_task')

  if (el) { initApp(el) }
})
