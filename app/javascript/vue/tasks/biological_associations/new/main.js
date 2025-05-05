import { createApp } from 'vue'
import App from './app.vue'
import { createPinia } from 'pinia'

function initApp(element) {
  const app = createApp(App)

  app.use(createPinia())
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#new_biological_association_task')

  if (el) {
    initApp(el)
  }
})
