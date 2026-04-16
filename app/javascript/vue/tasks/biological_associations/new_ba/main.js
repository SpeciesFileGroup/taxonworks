import { createApp } from 'vue'
import App from './app.vue'
import { createPinia } from 'pinia'

function initApp(element) {
  const app = createApp(App)

  app.use(createPinia())
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#new_ba_task')

  if (el) {
    initApp(el)
  }
})
