import { createApp } from 'vue'
import App from './app.vue'

function initApp (element) {
  const app = createApp(App)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#edit_anatomical_part_task')

  if (el) { initApp(el) }
})
