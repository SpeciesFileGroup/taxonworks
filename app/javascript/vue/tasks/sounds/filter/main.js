import { createApp } from 'vue'
import App from './app.vue'

function initApp(element) {
  const app = createApp(App)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-filter-sounds')

  if (el) {
    initApp(el)
  }
})
