import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import vHotkey from 'plugins/v-hotkey'

function initApp (element) {
  const app = createApp(App)
  const pinia = createPinia()

  app.directive('hotkey', vHotkey)
  app.use(pinia)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-simple-new-specimen')

  if (el) { initApp(el) }
})
