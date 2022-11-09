import { createApp } from 'vue'
import App from './App.vue'

function initApp (element) {
  const app = createApp(App)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-simple-new-specimen')

  if (el) { initApp(el) }
})
