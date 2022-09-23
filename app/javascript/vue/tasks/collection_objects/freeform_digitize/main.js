import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'

function initApp (element) {
  const app = createApp(App)

  app.use(newStore())
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#freeform_digitize_task')

  if (el) { initApp(el) }
})
