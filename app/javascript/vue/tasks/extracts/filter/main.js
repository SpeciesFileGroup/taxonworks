import { createApp } from 'vue'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function initApp (element) {
  const app = createApp(App)

  app.directive('hotkey', hotkey)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-extract-filter-task')

  if (el) { initApp(el) }
})
