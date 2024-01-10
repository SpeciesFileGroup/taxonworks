import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

function initApp(element) {
  const app = createApp(App)

  app.use(createPinia())
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#new_field_occurrences_task')

  if (el) {
    initApp(el)
  }
})
