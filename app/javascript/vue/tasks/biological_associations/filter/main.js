import { createApp } from 'vue'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function initApp (element) {
  const app = createApp(App)

  app.directive('hotkey', hotkey)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-filter-biological-associations')

  if (el) { initApp(el) }
})
