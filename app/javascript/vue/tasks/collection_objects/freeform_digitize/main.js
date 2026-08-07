import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './app.vue'

function initApp(element) {
  const app = createApp(App)

  app.use(createPinia())
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#freeform_digitize_task')

  if (el) {
    initApp(el)
  }
})
