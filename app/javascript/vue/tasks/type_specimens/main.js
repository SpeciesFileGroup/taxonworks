import { createApp } from 'vue'
import { newStore } from './store/store.js'
import App from './app.vue'
import hotkey from 'plugins/v-hotkey'

function init () {
  const app = createApp(App)
  app.use(newStore())
  app.directive('hotkey', hotkey)
  app.mount('#vue_type_specimens')
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue_type_specimens')) {
    init()
  }
})
