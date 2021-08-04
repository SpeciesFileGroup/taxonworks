import { createApp } from 'vue'
import hotkey from 'plugins/v-hotkey'
import App from './app.vue'

function init () {
  const app = createApp(App)
  app.directive('hotkey', hotkey)
  app.mount('#search_locality')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#search_locality')) {
    init()
  }
})
